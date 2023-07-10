package integration.samples.springboot.socialmedia.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;

@RestControllerAdvice
public class AppExceptionalHandler {

    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    ErrorDetails handleAllException(Exception exception, WebRequest request) {
        return new ErrorDetails(exception.getMessage(), request.getDescription(false));
    }

    @ExceptionHandler(UserNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    ErrorDetails handleUserNotFoundException(Exception userNotFound, WebRequest request) {
        return new ErrorDetails(userNotFound.getMessage(), request.getDescription(false));
    }

    @ExceptionHandler(NegativeSentimentException.class)
    @ResponseStatus(HttpStatus.FORBIDDEN)
    ErrorDetails handleNegativeSentimentException(Exception negativeSentiment, WebRequest request) {
        return new ErrorDetails(negativeSentiment.getMessage(), request.getDescription(false));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    ErrorDetails handleMethodArgumentNotValid(MethodArgumentNotValidException methodArgNotvalid, WebRequest request) {
        return new ErrorDetails(methodArgNotvalid.getMessage(), request.getDescription(false));
    }
}
