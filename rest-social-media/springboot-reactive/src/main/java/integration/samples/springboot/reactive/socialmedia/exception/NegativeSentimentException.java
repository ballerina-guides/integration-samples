package integration.samples.springboot.reactive.socialmedia.exception;

public class NegativeSentimentException extends RuntimeException {
    public NegativeSentimentException(String message) {
        super(message);
    }
}
