import SwiftUI

//struct Dog: Codable, CustomStringConvertible, Identifiable {
struct Dog: Codable, Identifiable {
    var name: String
    var breed: String
    //var description: String { "\(name) is a \(breed)"}
    var id: String { name }
    
    // Can also specify different names to use for JSON keys.
    enum CodingKeys: CodingKey {
        case name
        case breed
    }
}

func getData<T>(for key: String, defaultingTo defaultValue: T) -> T where T: Decodable {
    if let data = UserDefaults.standard.data(forKey: key) {
        print("init: data =", data)
        if let decoded = try? JSONDecoder().decode(T.self, from: data) {
            return decoded
        }
    }
    return defaultValue
}

func setData<T>(for key: String, to value: T) where T: Encodable {
    if let encoded = try? JSONEncoder().encode(value) {
        if let json = String(data: encoded, encoding: .utf8) {
            print("setData: json =", json)
        }
        UserDefaults.standard.set(encoded, forKey: key)
    }
}

struct ContentView: View {
    private static let KEY = "dogs"
    
    @State private var breed = ""
    @State private var name = ""
    @State private var dogs: [Dog] // can't initialize this to an empty array!
    
    init() {
        dogs = getData(for: ContentView.KEY, defaultingTo: [])
    }
    
    func save() {
        setData(for: ContentView.KEY, to: dogs)
    }
    
    var body: some View {
        VStack {
            Form {
                TextField("Name", text: $name)
                TextField("Breed", text: $breed)
                Button("Add") {
                    dogs.append(Dog(name: name, breed: breed))
                    save()
                    name = ""
                    breed = ""
                }
            }
            Section(header: Text("Dogs")) {
                List {
                    ForEach(dogs) { dog in
                        //Text(String(describing: dog))
                        Text("\(dog.name) is a \(dog.breed)")
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
