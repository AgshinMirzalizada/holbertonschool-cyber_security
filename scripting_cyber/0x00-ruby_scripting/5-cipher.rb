class CaesarCipher
  def initialize(shift)
    @shift = shift
  end

  def encrypt(message)
    cipher(message, @shift)
  end

  def decrypt(message)
    # Decryption is simply reversing the shift
    cipher(message, -@shift)
  end

  private

  def cipher(message, shift)
    # Map every character in the string through the shift logic
    message.chars.map do |char|
      if char.match?(/[a-z]/)
        # Shift lowercase characters (ASCII 97 to 122)
        (((char.ord - 97 + shift) % 26) + 97).chr
      elsif char.match?(/[A-Z]/)
        # Shift uppercase characters (ASCII 65 to 90)
        (((char.ord - 65 + shift) % 26) + 65).chr
      else
        # Leave spaces, punctuation, and symbols unchanged
        char
      end
    end.join
  end
end
