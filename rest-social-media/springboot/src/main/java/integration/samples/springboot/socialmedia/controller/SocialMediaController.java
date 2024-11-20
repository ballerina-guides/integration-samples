package integration.samples.springboot.socialmedia.controller;

import integration.samples.springboot.socialmedia.exception.ErrorDetails;
import integration.samples.springboot.socialmedia.exception.NegativeSentimentException;
import integration.samples.springboot.socialmedia.exception.UserNotFoundException;
import integration.samples.springboot.socialmedia.model.Post;
import integration.samples.springboot.socialmedia.model.User;
import integration.samples.springboot.socialmedia.repository.PostRepository;
import integration.samples.springboot.socialmedia.repository.UserRepository;
import integration.samples.springboot.socialmedia.sentiment.Sentiment;
import integration.samples.springboot.socialmedia.sentiment.SentimentProxy;
import integration.samples.springboot.socialmedia.sentiment.SentimentRequest;
import io.github.resilience4j.retry.annotation.Retry;
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
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Optional;

@RestController
public class SocialMediaController {

    private final UserRepository userRepository;
    private final PostRepository postRepository;
    private final SentimentProxy sentimentProxy;

    @Value("${sentiment.moderate}")
    private boolean moderate;

    @Autowired
    public SocialMediaController(UserRepository userRepository,
                                 PostRepository postRepository,
                                 SentimentProxy sentimentProxy) {
        this.userRepository = userRepository;
        this.postRepository = postRepository;
        this.sentimentProxy = sentimentProxy;
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
    @GetMapping("/social-media/users")
    public List<User> retrieveAllUsers() {
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
    @GetMapping("/social-media/users/{id}")
    public User retrieveUser(@PathVariable int id) {
        Optional<User> user = userRepository.findById(id);

        if (user.isEmpty())
            throw new UserNotFoundException("id: " + id);

        return user.get();
    }

    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Create user",
                    content = {@Content(mediaType = "application/json",
                            schema = @Schema(implementation = User.class))}),
            @ApiResponse(responseCode = "400", description = "Bad request",
                    content = {@Content(mediaType = "application/json",
                            schema = @Schema(implementation = ErrorDetails.class))})
    })
    @PostMapping("/social-media/users")
    public ResponseEntity<User> createUser(@Valid @RequestBody User user) {
        userRepository.save(user);
        return ResponseEntity.created(null).build();
    }

    @ApiResponses(value = {
            @ApiResponse(responseCode = "204", description = "Delete user")
    })
    @DeleteMapping("/social-media/users/{id}")
    public void deleteUser(@PathVariable int id) {
        userRepository.deleteById(id);
    }

    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Create post",
                    content = {@Content(mediaType = "application/json",
                            schema = @Schema(implementation = Post.class))}),
            @ApiResponse(responseCode = "404", description = "User not found",
                    content = {@Content(mediaType = "application/json",
                            schema = @Schema(implementation = ErrorDetails.class))})})
    @GetMapping("/social-media/users/{id}/posts")
    public List<Post> retrieveUserPosts(@PathVariable int id) {
        Optional<User> user = userRepository.findById(id);

        if (user.isEmpty())
            throw new UserNotFoundException("id: " + id);

        return user.get().getPosts();
    }

    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Create post",
                    content = {@Content(mediaType = "application/json",
                            schema = @Schema(implementation = User.class))}),
            @ApiResponse(responseCode = "403", description = "Negative sentiment detected",
                    content = {@Content(mediaType = "application/json",
                            schema = @Schema(implementation = ErrorDetails.class))}),
            @ApiResponse(responseCode = "404", description = "User not found",
                    content = {@Content(mediaType = "application/json",
                            schema = @Schema(implementation = ErrorDetails.class))})
    })
    @PostMapping("/social-media/users/{id}/posts")
    @Retry(name = "sentiment-api")
    public ResponseEntity<User> createUserPost(@PathVariable int id, @Valid @RequestBody Post post) {
        Optional<User> user = userRepository.findById(id);
        if (user.isEmpty()) {
            throw new UserNotFoundException("id: " + id);
        }
        if (moderate) {
            Sentiment sentiment = sentimentProxy.retrieveSentiment(new SentimentRequest(post.getDescription()));
            if (sentiment.getLabel().equalsIgnoreCase("neg")) {
                throw new NegativeSentimentException("Negative sentiment detected");
            }
        }
        post.setUser(user.get());
        postRepository.save(post);
        return ResponseEntity.created(null).build();
    }
}
