class MathUtils {
  static num mod(num x, num m) => ((x % m) + m) % m;

  static num wrap(num n, num min, num max) =>
      (n >= min && n < max) ? n : (mod(n - min, max - min) + min);
}
