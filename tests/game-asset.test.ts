import { describe, it, expect, beforeEach } from "vitest"

// Mock storage for game assets
const assets = new Map<number, { name: string; owner: string }>()
let lastAssetId = 0

// Mock functions to simulate contract behavior
function mintAsset(name: string, sender: string) {
  const newAssetId = ++lastAssetId
  assets.set(newAssetId, { name, owner: sender })
  return newAssetId
}

function transferAsset(assetId: number, sender: string, recipient: string) {
  const asset = assets.get(assetId)
  if (!asset) throw new Error("Asset not found")
  if (asset.owner !== sender) throw new Error("Not owner")
  asset.owner = recipient
  assets.set(assetId, asset)
  return true
}

function getAssetDetails(assetId: number) {
  return assets.get(assetId)
}

describe("Game Asset Contract", () => {
  beforeEach(() => {
    assets.clear()
    lastAssetId = 0
  })
  
  it("should mint a new asset", () => {
    const assetId = mintAsset("Sword", "player1")
    expect(assetId).toBe(1)
    const asset = getAssetDetails(assetId)
    expect(asset).toEqual({ name: "Sword", owner: "player1" })
  })
  
  it("should transfer an asset", () => {
    const assetId = mintAsset("Shield", "player1")
    const result = transferAsset(assetId, "player1", "player2")
    expect(result).toBe(true)
    const asset = getAssetDetails(assetId)
    expect(asset?.owner).toBe("player2")
  })
  
  it("should not transfer an asset if not owner", () => {
    const assetId = mintAsset("Potion", "player1")
    expect(() => transferAsset(assetId, "player2", "player3")).toThrow("Not owner")
  })
  
  it("should get asset details", () => {
    const assetId = mintAsset("Armor", "player1")
    const asset = getAssetDetails(assetId)
    expect(asset).toEqual({ name: "Armor", owner: "player1" })
  })
})

