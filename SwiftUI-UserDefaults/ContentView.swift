import SwiftUI

struct Dog: Codable, CustomStringConvertible, Identifiable {
    var name: String
    var breed: String
    var description: String { "\(name) is a \(breed)"}
    var id: String { name }
    
    // Can also use this to specify different names for the JSON keys.
    enum CodingKeys: CodingKey {
        case name
        case breed
    }
}

func deleteData(for key: String) {
    UserDefaults.standard.removeObject(forKey: key)
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
        print("init: dogs =", dogs)
    }
    
    func deleteAll() {
        deleteData(for: ContentView.KEY)
        dogs = []
    }
    
    func deleteDogs(at offsets: IndexSet) {
        dogs.remove(atOffsets: offsets)
        save()
    }
    
    func save() {
        setData(for: ContentView.KEY, to: dogs)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Section(header: Text("New Dog")) {
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
                }
                Section(header: Text("Current Dogs")) {
                    List {
                        ForEach(dogs) { dog in
                            Text(String(describing: dog))
                        }
                        .onDelete(perform: deleteDogs)
                    }
                    Button("Delete All", action: deleteAll)
                }
                Spacer()
            }.navigationBarTitle("Dog Collection", displayMode: .inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
