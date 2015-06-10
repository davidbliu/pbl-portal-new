echo "Running Unit Tests"

echo "Generating test fixtures"
rake fixtures:all

echo "Running Tabling Unit Tests"
rake test:tabling:generate_assignments_basic