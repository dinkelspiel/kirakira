module.exports = {
  content: [
    "./index.html",
    "./src/**/*.{gleam,mjs}",
    "../hermodr/src/**/*.{gleam,mjs}",
  ],
  theme: {
    extend: {
      animation: {
        wiggle: "wiggle 0.3s linear infinite",
      },
      keyframes: {
        wiggle: {
          "0%, 100%": { transform: "rotate(-8deg)" },
          "50%": { transform: "rotate(8deg)" },
        },
      },
    },
  },
  plugins: [],
};
