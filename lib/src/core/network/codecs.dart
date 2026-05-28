typedef JsonMap = Map<String, dynamic>;

typedef Decoder<T> = T Function(JsonMap json);

typedef Encoder<T> = JsonMap Function(T value);
