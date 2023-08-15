import lambda_function

def main():
    res = lambda_function.handler({"event": True}, {"context": True})
    print(res)


if __name__ == "__main__":
    main()

