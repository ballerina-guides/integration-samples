import ballerina/io;

public function main() {
    error? readEdi = read_edi();
    error? writeEdi = write_edi();

    io:println(readEdi);
    io:println(writeEdi);
}
