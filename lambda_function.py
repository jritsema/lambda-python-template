import json

# lambda entrypoint
def lambda_handler(event, context):
    print("lambda_function.lambda_handler")
    print(json.dumps(event, indent=2))
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "event": event
        })
    }
