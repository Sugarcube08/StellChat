.PHONY: dev reset-demo build clean test check-health

# Default target starts the laboratory dev stack
dev:
	@echo "🚀 Starting StellChat Local Laboratory..."
	@chmod +x ./scripts/dev.sh
	@./scripts/dev.sh

# Reset demo wipes container state, databases, redeploys contracts and creates funded test wallets
reset-demo:
	@echo "🔄 Resetting StellChat Demo Environment..."
	@docker compose -f docker-compose.local.yml down -v
	@echo " Wiped existing databases, redis caches, and MinIO storage volumes."
	@chmod +x ./scripts/dev.sh
	@./scripts/dev.sh
	@echo "✅ Demo reset complete! Standalone ledger is funded and verifier contract redeployed."

# Run tests
test:
	@echo "🧪 Running backend E2E integration tests..."
	@cd apps/backend && npm run test:e2e

# Clean temporary outputs
clean:
	@echo "🧹 Cleaning temporary files..."
	@rm -rf zk/build/*
	@rm -rf apps/backend/dist
	@rm -rf apps/prover/node_modules
	@rm -rf apps/mobile/build

# Check health of services
check-health:
	@echo "🏥 Checking local laboratory services health..."
	@echo "--- Backend Health ---"
	@curl -s http://localhost:3000/health || echo "❌ Backend Offline"
	@echo "\n--- Prover Health ---"
	@curl -s http://localhost:5001/health || echo "❌ Prover Offline"
	@echo "\n--- Horizon Health ---"
	@curl -s http://localhost:8000/ || echo "❌ Horizon Offline"
	@echo "\n--- MinIO Health ---"
	@curl -s http://localhost:9000/minio/health/live || echo "❌ MinIO Offline"
