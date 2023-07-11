package integration.samples.springboot.reactive.socialmedia.repository;

import integration.samples.springboot.reactive.socialmedia.model.User;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

public interface UserRepository {
    Flux<User> findAll();

    Mono<User> save(User user);

    Mono<User> findById(long id);

    Mono<Long> deleteById(long id);
}
