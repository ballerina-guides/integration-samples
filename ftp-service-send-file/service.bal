import ballerina/ftp;
import ballerina/io;

listener ftp:Listener fileListener = check new ({
    host: "ftp.example.com",
    auth: {
        credentials: {
            username: "user1",
            password: "pass456"
        }
    },
    path: "/home/in",
    fileNamePattern: "(.*).txt"
});

service on fileListener {

    remote function onFileChange(ftp:WatchEvent & readonly event, ftp:Caller caller) 
            returns error? {
                
        foreach ftp:FileInfo addedFile in event.addedFiles {
            stream<io:Block, io:Error?> fileStream = check 
                            io:fileReadBlocksAsStream("./local/appendFile.txt", 7);
            check caller->append(addedFile.path, fileStream);
            check fileStream.close();
        }
    }
}