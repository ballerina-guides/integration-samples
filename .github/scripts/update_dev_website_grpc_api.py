from common_utils import update_md


def main():
    update_md('grpc_api/grpc_api.bal', 'grpc-api.md',
              'update-grpc-api', 'gRPC API')
    update_md('grpc_api/descriptor_record_store.proto', 'grpc-api-proto.md',
              'update-grpc-api-proto', 'gRPC API')
main()
