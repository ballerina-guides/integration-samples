package integration.samples.springboot.socialmedia.repository;

import integration.samples.springboot.socialmedia.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Integer> {
}
