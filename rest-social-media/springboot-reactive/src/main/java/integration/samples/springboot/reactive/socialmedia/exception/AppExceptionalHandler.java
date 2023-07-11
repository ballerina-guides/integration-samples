package integration.samples.springboot.reactive.socialmedia.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.bind.support.WebExchangeBindException;

import java.util.Map;
import java.util.stream.Collectors;

@RestControllerAdvice
public class AppExceptionalHandler {

    @ExceptionHandler(UserNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    ErrorDetails onUserNotFound(UserNotFoundException userNotFound, ServerHttpRequest request) {
        return new ErrorDetails(userNotFound.getMessage(), Map.of("uri", request.getURI().getPath()));
    }

    @ExceptionHandler(NegativeSentimentException.class)
    @ResponseStatus(HttpStatus.FORBIDDEN)
    ErrorDetails onNegativeSentiment(NegativeSentimentException negativeSentiment, ServerHttpRequest request) {
        return new ErrorDetails(negativeSentiment.getMessage(), Map.of("uri", request.getURI().getPath()));
    }

    @ExceptionHandler(WebExchangeBindException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    ErrorDetails onMethodArgumentNotValid(WebExchangeBindException webExchangeBindException,
                                          ServerHttpRequest request) {
        return new ErrorDetails("Request validation failed", Map.of(
                "uri", request.getURI().getPath(),
                "failedValidations", webExchangeBindException.getFieldErrors().stream()
                        .map(fe -> Map.of(fe.getField(), fe.getDefaultMessage()))
                        .collect(Collectors.toList())
        ));
    }
}
