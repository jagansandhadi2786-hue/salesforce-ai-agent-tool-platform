import { createElement } from "lwc";
import AiAgentConsole from "c/aiAgentConsole";

describe("c-ai-agent-console", () => {
  afterEach(() => {
    // Clean up the DOM after each test.
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders the AI Agent Console component", () => {
    // Arrange
    const element = createElement("c-ai-agent-console", {
      is: AiAgentConsole
    });

    // Act
    document.body.appendChild(element);

    // Assert
    expect(element).toBeTruthy();
  });
});
