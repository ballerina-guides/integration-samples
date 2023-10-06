package integration.samples.springboot.socialmedia.repository;

import integration.samples.springboot.socialmedia.model.Post;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PostRepository extends JpaRepository<Post, Integer> {
}
