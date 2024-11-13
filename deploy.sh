# Clone the repository and navigate to it
$ git clone <repository-url>
$ cd stock_predictor_saas

# Create and populate .env file
$ cat > .env << EOL
SECRET_KEY=your-secret-key
DATABASE_URL=postgresql://test:test@test-db:5432/test_db
REDIS_URL=redis://redis:6379
LOG_LEVEL=INFO
EOL

# Build and start the containers
$ docker-compose up --build -d

# Run the tests
$ docker-compose run tests pytest

# Test the API endpoints
$ curl -X POST "http://localhost:8000/register" \
    -H "Content-Type: application/json" \
    -d '{"username":"testuser","password":"testpass"}'

$ TOKEN=$(curl -s -X POST "http://localhost:8000/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=testuser&password=testpass" | jq -r .access_token)

# Test predictions for multiple stocks
$ for symbol in AAPL MSFT GOOGL TSLA META NVDA; do
    echo "Testing $symbol:"
    curl -s -X GET "http://localhost:8000/predict/$symbol" \
        -H "Authorization: Bearer $TOKEN" | jq .
    sleep 1
done

# Check the test coverage
$ docker-compose run tests pytest --cov-report=html

# Check the logs
$ docker-compose logs -f web