import ballerina/file;
import ballerina/io;
import ballerina/log;

public function main() returns error? {
    file:MetaData[] inputDirectory = check file:readDir("data");
    string outputDirectory = "target/messages/";
    foreach file:MetaData readDirResult in inputDirectory {
        string xmlFilePath = readDirResult.absPath;
        xml message = check io:fileReadXml(xmlFilePath);
        string city = (message/**/<person>/**/<city>).data();
        string fileName = check file:basename(xmlFilePath);
        if city == "London" {
            log:printInfo("UK message");
            check io:fileWriteXml(outputDirectory + "uk/" + fileName, message);
        } else {
            log:printInfo("Other message");
            check io:fileWriteXml(outputDirectory + "others/" + fileName, message);
        }
    }
}
