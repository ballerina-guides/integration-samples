package integration.samples.springboot.reactive.socialmedia.repository;

import integration.samples.springboot.reactive.socialmedia.model.Post;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

public interface PostRepository {
    Flux<Post> findPostForUser(long userId);
    Mono<Post> save(long userId, Post post);
}
