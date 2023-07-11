package integration.samples.springboot.reactive.socialmedia.controller;

import integration.samples.springboot.reactive.socialmedia.exception.ErrorDetails;
import integration.samples.springboot.reactive.socialmedia.exception.NegativeSentimentException;
import integration.samples.springboot.reactive.socialmedia.exception.UserNotFoundException;
import integration.samples.springboot.reactive.socialmedia.model.Post;
import integration.samples.springboot.reactive.socialmedia.model.User;
import integration.samples.springboot.reactive.socialmedia.repository.PostRepository;
import integration.samples.springboot.reactive.socialmedia.repository.UserRepository;
import integration.samples.springboot.reactive.socialmedia.sentiment.SentimentAnalysisClient;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.List;

@RestController
@RequestMapping("/social-media/users")
public class SocialMediaController {
    private final UserRepository userRepository;
    private final PostRepository postRepository;
    private final SentimentAnalysisClient sentimentAnalysisClient;

    @Value("${sentiment.moderate}")
    private boolean moderate;

    @Autowired
    public SocialMediaController(UserRepository userRepository, PostRepository postRepository,
                                 SentimentAnalysisClient sentimentAnalysisClient) {
        this.userRepository = userRepository;
        this.postRepository = postRepository;
        this.sentimentAnalysisClient = sentimentAnalysisClient;
    }

    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Get users",
                    content = {
                            @Content(
                                    mediaType = "application/json",
                                    array = @ArraySchema(
                                            schema = @Schema(implementation = User.class)
                                    )
                            )
                    })
    })
    @GetMapping
    public Flux<User> retrieveAllUsers() {
        return userRepository.findAll();
    }

    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Get user",
                    content = {
                            @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = User.class)
                            )
                    }),
            @ApiResponse(
                    responseCode = "404",
                    description = "User not found",
                    content = {
                            @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = ErrorDetails.class)
                            )
                    })
    })
    @GetMapping("/{id}")
    public Mono<User> retrieveUser(@PathVariable long id) {
        return userRepository
                .findById(id)
                .switchIfEmpty(
                        Mono.error(new UserNotFoundException(String.format("User not found for id: %d", id)))
                );
    }

    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "201",
                    description = "Create user",
                    content = {
                            @Content(
                                    mediaType = "application/json"
                            )
                    }),
            @ApiResponse(
                    responseCode = "400",
                    description = "Bad request",
                    content = {
                            @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = ErrorDetails.class)
                            )
                    })
    })
    @PostMapping
    public Mono<ResponseEntity<Void>> createUser(@Valid @RequestBody User user) {
        return userRepository
                .save(user)
                .map(savedUser -> ResponseEntity.created(null).build());
    }

    @ApiResponses(value = {
            @ApiResponse(responseCode = "204", description = "Delete user")
    })
    @DeleteMapping("/{id}")
    public Mono<ResponseEntity<Void>> deleteUser(@PathVariable long id) {
        return userRepository
                .deleteById(id)
                .map(v -> ResponseEntity.noContent().build());
    }

    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Get user posts",
                    content = {
                            @Content(
                                    mediaType = "application/json",
                                    array = @ArraySchema(
                                            schema = @Schema(implementation = Post.class)
                                    )
                            )
                    }),
            @ApiResponse(
                    responseCode = "404",
                    description = "User not found",
                    content = {
                            @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = ErrorDetails.class)
                            )
                    })
    })
    @GetMapping("/{id}/posts")
    public Flux<Post> retrieveUserPosts(@PathVariable long id) {
        return userRepository
                .findById(id)
                .switchIfEmpty(
                        Mono.error(new UserNotFoundException(String.format("User not found for id: %d", id)))
                ).flatMapMany(user -> postRepository.findPostForUser(id));
    }

    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "201",
                    description = "Create user post",
                    content = {
                            @Content(
                                    mediaType = "application/json"
                            )
                    }),
            @ApiResponse(
                    responseCode = "404",
                    description = "User not found",
                    content = {
                            @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = ErrorDetails.class)
                            )
                    }),
            @ApiResponse(
                    responseCode = "400",
                    description = "Bad request",
                    content = {
                            @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = ErrorDetails.class)
                            )
                    })
    })
    @PostMapping("/{id}/posts")
    public Mono<ResponseEntity<Void>> createUserPost(@PathVariable int id, @Valid @RequestBody Post post) {
        return userRepository
                .findById(id)
                .switchIfEmpty(
                        Mono.error(new UserNotFoundException(String.format("User not found for id: %d", id)))
                ).flatMap(user -> moderateContent(post))
                .flatMap(moderatedPost -> postRepository.save(id, post))
                .map(savedPost -> ResponseEntity.created(null).build());
    }

    private Mono<Post> moderateContent(Post post) {
        if (!moderate) {
            return Mono.just(post);
        }
        return sentimentAnalysisClient
                .retrieveSentiment(post.getDescription())
                .map(sentiment -> !sentiment.getLabel().equalsIgnoreCase("neg"))
                .switchIfEmpty(Mono.error(new NegativeSentimentException("Negative sentiment detected")))
                .map(sentiment -> post);
    }
}
