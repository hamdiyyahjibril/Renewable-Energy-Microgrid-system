import { describe, it, expect, beforeEach } from "vitest"

// Mock the Clarity functions and types
const mockClarity = {
  tx: {
    sender: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
  },
  types: {
    uint: (value: number) => ({ type: "uint", value }),
    int: (value: number) => ({ type: "int", value }),
    principal: (value: string) => ({ type: "principal", value }),
  },
}

// Mock contract state
let gridEnergyBalance = 0
let lastStorageId = 0
const energyStorage = new Map()

// Mock contract calls
const contractCalls = {
  "add-storage": (capacity: number) => {
    const storageId = ++lastStorageId
    energyStorage.set(storageId, {
      capacity: mockClarity.types.uint(capacity),
      "current-level": mockClarity.types.uint(0),
      owner: mockClarity.types.principal(mockClarity.tx.sender),
    })
    return { success: true, value: mockClarity.types.uint(storageId) }
  },
  "store-energy": (storageId: number, amount: number) => {
    const storage = energyStorage.get(storageId)
    if (!storage) {
      return { success: false, error: "err-not-found" }
    }
    const newLevel = storage["current-level"].value + amount
    if (newLevel > storage.capacity.value) {
      return { success: false, error: "err-unauthorized" }
    }
    storage["current-level"] = mockClarity.types.uint(newLevel)
    gridEnergyBalance -= amount
    return { success: true, value: true }
  },
  "release-energy": (storageId: number, amount: number) => {
    const storage = energyStorage.get(storageId)
    if (!storage || storage["current-level"].value < amount) {
      return { success: false, error: "err-unauthorized" }
    }
    storage["current-level"] = mockClarity.types.uint(storage["current-level"].value - amount)
    gridEnergyBalance += amount
    return { success: true, value: true }
  },
  "update-grid-balance": (amount: number) => {
    if (mockClarity.tx.sender !== "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM") {
      return { success: false, error: "err-owner-only" }
    }
    gridEnergyBalance += amount
    return { success: true, value: mockClarity.types.int(gridEnergyBalance) }
  },
  "get-storage": (storageId: number) => {
    const storage = energyStorage.get(storageId)
    return storage ? { success: true, value: storage } : { success: false, error: "err-not-found" }
  },
  "get-grid-balance": () => {
    return { success: true, value: mockClarity.types.int(gridEnergyBalance) }
  },
}

describe("Grid Stability Contract", () => {
  beforeEach(() => {
    gridEnergyBalance = 0
    lastStorageId = 0
    energyStorage.clear()
  })
  
  it("should add energy storage facility", () => {
    const result = contractCalls["add-storage"](1000)
    expect(result.success).toBe(true)
    expect(result.value).toEqual(mockClarity.types.uint(1))
    
    const storage = energyStorage.get(1)
    expect(storage).toBeDefined()
    expect(storage.capacity).toEqual(mockClarity.types.uint(1000))
  })
  
  it("should store excess energy", () => {
    contractCalls["add-storage"](1000)
    const result = contractCalls["store-energy"](1, 500)
    expect(result.success).toBe(true)
    expect(result.value).toBe(true)
    
    const storage = energyStorage.get(1)
    expect(storage["current-level"]).toEqual(mockClarity.types.uint(500))
    expect(gridEnergyBalance).toBe(-500)
  })
  
  it("should release stored energy", () => {
    contractCalls["add-storage"](1000)
    contractCalls["store-energy"](1, 500)
    const result = contractCalls["release-energy"](1, 200)
    expect(result.success).toBe(true)
    expect(result.value).toBe(true)
    
    const storage = energyStorage.get(1)
    expect(storage["current-level"]).toEqual(mockClarity.types.uint(300))
    expect(gridEnergyBalance).toBe(-300)
  })
  
  it("should update grid energy balance", () => {
    const result = contractCalls["update-grid-balance"](1000)
    expect(result.success).toBe(true)
    expect(result.value).toEqual(mockClarity.types.int(1000))
    expect(gridEnergyBalance).toBe(1000)
  })
  
  it("should get storage facility details", () => {
    contractCalls["add-storage"](1000)
    contractCalls["store-energy"](1, 500)
    const result = contractCalls["get-storage"](1)
    expect(result.success).toBe(true)
    expect(result.value.capacity).toEqual(mockClarity.types.uint(1000))
    expect(result.value["current-level"]).toEqual(mockClarity.types.uint(500))
  })
  
  it("should get current grid energy balance", () => {
    contractCalls["update-grid-balance"](1000)
    const result = contractCalls["get-grid-balance"]()
    expect(result.success).toBe(true)
    expect(result.value).toEqual(mockClarity.types.int(1000))
  })
})

