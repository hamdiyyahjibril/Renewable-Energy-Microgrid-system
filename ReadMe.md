# Decentralized Renewable Energy Microgrid

A blockchain-based smart contract system for managing local renewable energy microgrids, enabling peer-to-peer energy trading and grid stability management.

## Overview

This project implements a decentralized energy microgrid system using smart contracts to facilitate local energy production, consumption, trading, and grid stability. The system enables communities to manage their own renewable energy resources efficiently while maintaining grid reliability.

## System Architecture

The microgrid system consists of four main smart contracts:

### Energy Production Contract
Manages renewable energy generation within the microgrid:
- Tracks real-time energy production from solar, wind, and other renewable sources
- Records historical generation data
- Verifies and certifies renewable energy credits
- Monitors generator health and maintenance status

### Energy Consumption Contract
Monitors and manages energy usage:
- Real-time consumption tracking for all grid participants
- Smart meter integration
- Usage analytics and reporting
- Demand forecasting
- Automated billing based on consumption

### Trading Contract
Enables peer-to-peer energy trading:
- Automated matching of producers and consumers
- Dynamic pricing based on supply and demand
- Real-time settlement of energy trades
- Trading history and analytics
- Integration with external pricing oracles

### Grid Stability Contract
Ensures reliable grid operation:
- Battery storage management
- Load balancing
- Demand response programs
- Emergency protocols
- Grid performance monitoring

## Getting Started

### Prerequisites
- Ethereum development environment (Hardhat/Truffle)
- Node.js version 16 or higher
- MetaMask or similar Web3 wallet
- Smart meter integration capability

### Installation
1. Clone the repository:
```bash
git clone https://github.com/your-org/microgrid-system.git
cd microgrid-system
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment variables:
```bash
cp .env.example .env
# Edit .env with your settings
```

4. Deploy contracts:
```bash
npx hardhat run scripts/deploy.js --network <your-network>
```

## Usage

### For Energy Producers
1. Register your renewable energy source
2. Connect your smart meter
3. Start generating and selling excess energy

### For Energy Consumers
1. Create an account and connect your smart meter
2. Set trading preferences
3. Begin participating in the local energy market

### For Grid Operators
1. Monitor grid stability metrics
2. Manage energy storage systems
3. Implement demand response programs

## Smart Contract Interaction

### Energy Production
```solidity
function registerProducer(address _producer, uint256 _capacity) external;
function recordGeneration(uint256 _amount, uint256 _timestamp) external;
function getProducerStats(address _producer) external view returns (Stats memory);
```

### Energy Consumption
```solidity
function recordConsumption(uint256 _amount, uint256 _timestamp) external;
function getConsumerStats(address _consumer) external view returns (Stats memory);
function setConsumptionLimit(uint256 _limit) external;
```

### Trading
```solidity
function createSellOrder(uint256 _amount, uint256 _price) external;
function createBuyOrder(uint256 _amount, uint256 _maxPrice) external;
function executeMatch(uint256 _orderId1, uint256 _orderId2) external;
```

### Grid Stability
```solidity
function updateStorageLevel(uint256 _level) external;
function triggerDemandResponse() external;
function getGridMetrics() external view returns (Metrics memory);
```

## Security Considerations

- Multi-signature requirements for critical operations
- Oracle data verification
- Rate limiting for trading operations
- Emergency shutdown procedures
- Regular security audits
- Hardware security for smart meters

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.

## Support

For technical support or questions:
- Create an issue in the GitHub repository
- Contact the development team at support@microgrid-project.com
- Join our Discord community

## Roadmap

### Phase 1 (Q2 2025)
- Basic smart contract deployment
- Smart meter integration
- Simple trading functionality

### Phase 2 (Q3 2025)
- Advanced trading features
- Grid stability improvements
- Mobile app release

### Phase 3 (Q4 2025)
- AI-powered predictions
- Cross-microgrid trading
- Enhanced security features
