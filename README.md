# Codeable
A simple and extendable means to encode and decode swift objects.

## Simple Example
In this example lets define ways to represent people, animals, and genders.

```swift
struct Person {
    let name: String
    let gender: Gender
    let pets: [Animal]?
}

struct Animal {
    let name: String
}

enum Gender: Int {
    case Other, Male, Female
}
```

Let make `Person` and `Animal` conform to `Codeable`. For the sake of brevity, I've only show the implementation for `Person`.

```swift
extension Person: Codeable {
    func encode(encoder: EncoderType) throws {
        try encoder.encode(name, key: "name")
        try encoder.encode(gender, key: "gender")
        try encoder.encode(pets, key: "pets")
    }
    
    init(decoder: DecoderType) throws {
        name = try decoder.decode("name")
        gender = try decoder.decode("gender")
        pets = try decoder.decode("pets")
    }
}
```

As you can see conforming to `Codeable` looks very similar to conforming to NSCoding. One main difference is that `Codeable` supports structs and enums.

Enums aren't supported out of the box but if they conform to `RawRepresentable` they can be supported simply by conforming to `EnumCodeable`.

```swift
extension Gender: EnumCodeable {}
```

Encoding and Decoding an object is easy. All of the encoding/decoding logic is encapsulated in `EncoderType` and `DecoderType`'s default implementaion thanks to Swift protocol extensions.

Here's how to encode me:

```swift
let shawn = Person(name: "Shawn", gender: .Male, pets: nil)
let encoded = try! KeyedCoder.encodeRootObject(shawn)
// ["gender": 1, "name": "Shawn"]
```

## Advanced Example
This whole project spawned from my frustration with code duplication; I was decoding JSON from a webservice and decoding objects previously archived to disk using nearly identical implementations.

For this example, lets say that the webservice we're interacting with stores pets as an array of strings and we archive them to disk as an array of dictionaries. This becomes a problem because you can't change a webservice to suit your needs and JSON backed model objects are not sensible. 

To solve this we make what I'm calling a _"phantom subclass"_ of KeyedCoder. Lets call it JSONCoder. 

```swift
class JSONCoder: KeyedCoder {}
```

> _Note:_ I don't need to subclass KeyedCoder. I'm simply doing it because its a one-liner. KeyedCoder is merely a storage facitly for the logic contained in `EncoderType` and `DecoderType`.

Next, we alter our implementation of `Person`'s `init(decoder: DecoderType) throws` so that we have a separate code path for JSONCoder.

```swift
init(decoder: DecoderType) throws {
    switch decoder {
    case let json as JSONCoder:
        name = try json.decode("name")
        gender = try json.decode("gender")
        let petNames: [String]? = try json.decode("petNames")
        pets = petNames != nil ? petNames!.map { Animal(name: $0) } : nil
        
    default:
        name = try decoder.decode("name")
        gender = try decoder.decode("gender")
        pets = try decoder.decode("pets")
  }
}
```

Now use JSONCoder in place of KeyedCoder.

```swift
let json: [String: AnyObject] = ["name": "Craig", "gender": 1, "petNames": ["Fluffy"]]
let craig: Person = try! JSONCoder.decodeRootObject(json)
// "Person(name: "Craig", gender: Gender.Male, pets: Optional([Animal(name: "Fluffy")]))"
```

Et Voila! A default implementaion for KeyedCoder and a specailized implementation for interacting with a webservice.

### Contact

I'm [@shawnthroop on Twitter](http://twitter.com/shawnthroop) and [App.net](http://app.net/shawnthroop).
