package dop.example;

sealed interface Shape permits Circle, Rectangle {}

record Circle(double radius) implements Shape {}

record Rectangle(double width, double height) implements Shape {}

public class Main {
    public static double calculateArea(Shape shape) {
        return switch (shape) {
            case Circle circle -> Math.PI * circle.radius() * circle.radius();
            case Rectangle rectangle -> rectangle.width() * rectangle.height();
        };
    }

    public static void main(String[] args) {
        System.out.println(calculateArea(new Circle(10)));
    }
}