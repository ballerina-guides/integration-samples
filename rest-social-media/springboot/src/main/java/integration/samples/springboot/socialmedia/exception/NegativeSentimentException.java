package integration.samples.springboot.socialmedia.exception;

public class NegativeSentimentException extends RuntimeException {

    public NegativeSentimentException(String message) {
        super(message);
    }
}
