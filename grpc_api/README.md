## gRPC API

This elaborates on how to build gRPC API using Ballerina for any given protocol definition.

Steps to follow:

1. Generate the stub file using the following command:

```bash
bal grpc --input <proto-file-path> --output <output-directory>
```
- `<proto-file-path>` - Path of the proto file. Create a new proto file (e.g. descriptor_record_store.proto), add the service definition to it, and point to the path of the proto file.
- `<output-directory>` - Path of the output directory for the generated stub file.

2. Add the generated stub file to the same project in which the Ballerina service is written.

3. Build the Ballerina project.