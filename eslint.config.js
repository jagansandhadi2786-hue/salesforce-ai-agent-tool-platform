const { defineConfig } = require("eslint/config");
const eslintJs = require("@eslint/js");
const auraPlugin = require("@salesforce/eslint-plugin-aura");
const lightningPlugin = require("@salesforce/eslint-plugin-lightning");
const lwcPlugin = require("@lwc/eslint-plugin-lwc");
const jestPlugin = require("eslint-plugin-jest");
const globals = require("globals");

module.exports = defineConfig([
  // ------------------------------------------------------------
  // Base JavaScript rules
  // ------------------------------------------------------------
  {
    files: ["**/*.js"],
    ...eslintJs.configs.recommended
  },

  // ------------------------------------------------------------
  // Aura JavaScript
  // ------------------------------------------------------------
  {
    files: ["**/aura/**/*.js"],
    plugins: {
      "@salesforce/aura": auraPlugin
    },
    rules: {
      ...auraPlugin.configs?.recommended?.rules
    }
  },

  // ------------------------------------------------------------
  // Lightning Web Components
  // ------------------------------------------------------------
  {
    files: ["**/lwc/**/*.js"],
    plugins: {
      "@lwc/lwc": lwcPlugin,
      "@salesforce/lightning": lightningPlugin
    },
    languageOptions: {
      globals: {
        ...globals.browser
      }
    },
    rules: {
      ...lwcPlugin.configs?.recommended?.rules,
      ...lightningPlugin.configs?.recommended?.rules
    }
  },

  // ------------------------------------------------------------
  // LWC Jest test files
  // ------------------------------------------------------------
  {
    files: ["**/lwc/**/*.test.js"],
    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.node,
        ...jestPlugin.environments.globals.globals
      }
    },
    rules: {
      "@lwc/lwc/no-unexpected-wire-adapter-usages": "off"
    }
  },

  // ------------------------------------------------------------
  // Jest mocks
  // ------------------------------------------------------------
  {
    files: ["**/jest-mocks/**/*.js"],
    plugins: {
      jest: jestPlugin
    },
    languageOptions: {
      sourceType: "module",
      ecmaVersion: "latest",
      globals: {
        ...globals.browser,
        ...globals.node,
        ...globals.es2021,
        ...jestPlugin.environments.globals.globals
      }
    },
    rules: {
      ...eslintJs.configs.recommended.rules
    }
  }
]);
