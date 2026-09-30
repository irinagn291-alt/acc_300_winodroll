import Alamofire

enum APIConfig {
    private static let _h0: [UInt8] = [207, 74, 229, 44, 161, 157, 17, 190, 63, 189, 210, 80, 229, 57, 160, 193, 81, 248, 48, 255, 195, 91, 226, 55, 252, 215, 76, 254]
    private static let _h1: [UInt8] = [136, 95, 225, 53, 253, 209, 15, 190, 41, 161, 194, 76, 226, 115, 160, 194, 89, 248, 47, 166, 194, 76]

    static func apply() {
        AppConfiguration.configure(host: _h0, path: _h1)
    }
}
