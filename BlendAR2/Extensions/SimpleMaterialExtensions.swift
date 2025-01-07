import RealityKit

extension SimpleMaterial {
    /// テクスチャを適用するためのカスタムイニシャライザ
    init(textureResource: TextureResource?) {
        if let texture = textureResource {
            let materialTexture = MaterialParameters.Texture(texture)
            self.init(color: .white, isMetallic: false)
            self.color = .init(tint: .white, texture: materialTexture)
        } else {
            self.init(color: .white, isMetallic: false)
        }
    }
}
