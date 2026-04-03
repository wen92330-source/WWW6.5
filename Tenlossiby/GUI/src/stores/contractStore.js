import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useContractStore = defineStore('contract', () => {
  // 合约状态
  const contracts = ref({
    day1: {
      count: 0,
      interactionCount: 0
    },
    day2: {
      name: "",
      bio: "",
      interactionCount: 0,
      hasStored: false,
      hasRetrieved: false
    },
    day3: {
      candidates: [],
      voteCount: {},
      interactionCount: 0
    },
    day4: {
      owner: "",
      item: "",
      auctionEndTime: 0,
      highestBidder: "",
      highestBid: 0,
      ended: false,
      bids: {},
      bidders: [],
      interactionCount: 0
    },
    day5: {
      owner: "",
      treasureAmount: 0,
      withdrawalAllowance: {},
      hasWithdrawn: {},
      userAddress: "0x" + Math.random().toString(16).substr(2, 40),
      userAllowance: 0,
      interactionCount: 0
    },
    day6: {
      bankManager: "",
      members: [],
      registeredMembers: {},
      balance: {},
      userAddress: "0x" + Math.random().toString(16).substr(2, 40),
      interactionCount: 0,
      depositCount: 0,
      withdrawCount: 0
    },
    day7: {
      owner: "",
      userAddress: "",
      registeredFriends: {},
      friendList: [],
      balances: {},
      debts: {},
      interactionCount: 0
    },
    day8: {
        owner: "",
        userAddress: "",
        isUserAdmin: false,
        totalTipsReceived: 0,
        tipPerPerson: {},
        tipsPerCurrency: {},
        supportedCurrencies: ["USD", "EUR", "JPY", "INR"],
        conversionRates: {
          "USD": 500000000000000,
          "EUR": 600000000000000,
          "JPY": 4000000000000,
          "INR": 7000000000000
        },
        interactionCount: 0
      },
      day9: {
        owner: "",
        userAddress: "",
        isUserAdmin: false,
        scientificCalculatorAddress: "",
        isAddressSet: false,
        operationCount: 0,
        operationHistory: [],
        interactionCount: 0,
        challengeTasks: {
          setAddress: false,
          powerCalc: false,
          sqrtCalc: false,
          permissionCheck: false
        }
      },
      day10: {
        owner: "",
        userAddress: "",
        userProfile: {
          name: "",
          weight: 0,
          isRegistered: false
        },
        workoutHistory: [],
        totalWorkouts: 0,
        totalDistance: 0,
        milestones: {
          weightGoal: { achieved: false, timestamp: 0, title: '减重目标达成', icon: '⚖️' },
          workouts10: { achieved: false, timestamp: 0, title: '10次运动', icon: '🏃' },
          workouts50: { achieved: false, timestamp: 0, title: '50次运动大师', icon: '🏆' },
          distance100K: { achieved: false, timestamp: 0, title: '100公里里程碑', icon: '🌍' }
        },
        interactionCount: 0
      },
      day11: {
        owner: "",
        userAddress: "",
        contractBalance: 0,
        eventLog: [],
        interactionCount: 0
      }
    })

  // 工具函数：生成随机地址
  const generateAddress = () => {
    return "0x" + Math.random().toString(16).substr(2, 40)
  }

  // 初始化指定Day的合约
  const initializeContract = (dayNumber) => {
    const contractKey = `day${dayNumber}`
    const contract = contracts.value[contractKey]

    if (!contract) {
      console.warn(`Contract for day ${dayNumber} not found`)
      return
    }

    // 根据不同Day进行初始化
    switch (dayNumber) {
      case 5:
        if (!contract.owner) {
          contract.owner = generateAddress()
        }
        if (!contract.userAddress) {
          contract.userAddress = generateAddress()
        }
        break

      case 6:
        if (contract.bankManager === '') {
          contract.bankManager = generateAddress()
          contract.members = [contract.bankManager]
          contract.registeredMembers = {
            [contract.bankManager]: true,
            [contract.userAddress]: true
          }
          contract.balance = {
            [contract.bankManager]: 0,
            [contract.userAddress]: 0
          }
          contract.members.push(contract.userAddress)
        }
        break

      case 7:
        if (contract.owner === '') {
          const owner = generateAddress()
          contract.owner = owner
          contract.userAddress = owner
          contract.registeredFriends[owner] = true
          contract.friendList.push(owner)
        }
        break

      case 8:
        if (contract.owner === '') {
          contract.owner = generateAddress()
          contract.userAddress = generateAddress()
        }
        break

      case 9:
        if (contract.owner === '') {
          contract.owner = generateAddress()
          contract.userAddress = generateAddress()
          contract.isUserAdmin = false
        }
        break

      case 10:
        if (contract.owner === '') {
          contract.owner = generateAddress()
          contract.userAddress = generateAddress()
        }
        break

      case 11:
        if (contract.owner === '') {
          const owner = generateAddress()
          contract.owner = owner
          contract.userAddress = owner
          contract.contractBalance = 0
          contract.eventLog = []
        }
        break
    }
  }

  // 获取指定Day的合约
  const getContract = (dayNumber) => {
    return contracts.value[`day${dayNumber}`]
  }

  // 更新合约状态
  const updateContract = (dayNumber, updates) => {
    const contract = getContract(dayNumber)
    if (contract) {
      Object.assign(contract, updates)
    }
  }

  return {
    contracts,
    initializeContract,
    getContract,
    updateContract,
    generateAddress
  }
})
