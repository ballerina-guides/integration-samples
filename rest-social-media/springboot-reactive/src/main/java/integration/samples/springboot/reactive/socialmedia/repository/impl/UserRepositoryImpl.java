package integration.samples.springboot.reactive.socialmedia.repository.impl;

import integration.samples.springboot.reactive.socialmedia.model.User;
import integration.samples.springboot.reactive.socialmedia.repository.UserRepository;
import io.r2dbc.spi.Row;
import io.r2dbc.spi.RowMetadata;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDate;
import java.util.function.BiFunction;

@Repository
public class UserRepositoryImpl implements UserRepository {
    private static final BiFunction<Row, RowMetadata, User> MAPPING_FUNCTION = (row, rowMetadata) -> {
        User user = new User();
        user.setId(row.get("id", Long.class));
        user.setName(row.get("name", String.class));
        user.setBirthDate(row.get("birth_date", LocalDate.class));
        return user;
    };

    private final DatabaseClient dbClient;

    @Autowired
    public UserRepositoryImpl(DatabaseClient dbClient) {
        this.dbClient = dbClient;
    }

    @Override
    public Flux<User> findAll() {
        return dbClient.sql("SELECT * FROM user")
                .map(MAPPING_FUNCTION)
                .all();
    }

    @Override
    public Mono<User> save(User user) {
        return dbClient.sql("INSERT INTO  user (name, birth_date) VALUES (:name, :birthDate)")
                .filter((statement, next) -> statement.returnGeneratedValues("id").execute())
                .bind("name", user.getName())
                .bind("birthDate", user.getBirthDate())
                .fetch()
                .first()
                .map(row -> {
                    user.setId((long) row.get("id"));
                    return user;
                });
    }

    @Override
    public Mono<User> findById(long id) {
        return dbClient.sql("SELECT * FROM user WHERE id=:userId")
                .bind("userId", id)
                .map(MAPPING_FUNCTION)
                .first();
    }

    @Override
    public Mono<Long> deleteById(long id) {
        return dbClient.sql("DELETE FROM user WHERE id=:userId")
                .bind("userId", id)
                .fetch()
                .rowsUpdated();
    }
}
