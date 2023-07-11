package integration.samples.springboot.reactive.socialmedia.repository.impl;

import integration.samples.springboot.reactive.socialmedia.model.Post;
import integration.samples.springboot.reactive.socialmedia.repository.PostRepository;
import io.r2dbc.spi.Row;
import io.r2dbc.spi.RowMetadata;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.function.BiFunction;

@Repository
public class PostRepositoryImpl implements PostRepository {
    private static final BiFunction<Row, RowMetadata, Post> MAPPING_FUNCTION = (row, rowMetadata) -> {
        Post post = new Post();
        post.setId(row.get("id", Long.class));
        post.setDescription(row.get("description", String.class));
        return post;
    };

    private final DatabaseClient dbClient;

    @Autowired
    public PostRepositoryImpl(DatabaseClient dbClient) {
        this.dbClient = dbClient;
    }

    @Override
    public Flux<Post> findPostForUser(long userId) {
        return dbClient.sql("SELECT * FROM post WHERE user_id=:userId")
                .bind("userId", userId)
                .map(MAPPING_FUNCTION)
                .all();
    }

    @Override
    public Mono<Post> save(long userId, Post post) {
        return dbClient.sql("INSERT INTO  post (description, user_id) VALUES (:description, :userId)")
                .filter((statement, next) -> statement.returnGeneratedValues("id").execute())
                .bind("userId", userId)
                .bind("description", post.getDescription())
                .fetch()
                .first()
                .map(row -> {
                    post.setId((long) row.get("id"));
                    return post;
                });
    }
}
