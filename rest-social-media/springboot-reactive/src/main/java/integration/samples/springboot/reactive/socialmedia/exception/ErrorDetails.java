package integration.samples.springboot.reactive.socialmedia.exception;

import java.time.LocalDateTime;
import java.util.Map;

public class ErrorDetails {
    private final LocalDateTime timeStamp;
    private final String message;
    private final Map<String, Object> details;

    public ErrorDetails(String message, Map<String, Object> details) {
        this.timeStamp = LocalDateTime.now();
        this.message = message;
        this.details = details;
    }

    public LocalDateTime getTimeStamp() {
        return timeStamp;
    }

    public String getMessage() {
        return message;
    }

    public Map<String, Object> getDetails() {
        return details;
    }
}
