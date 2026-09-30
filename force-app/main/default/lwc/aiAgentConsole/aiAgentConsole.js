import { LightningElement } from 'lwc';
import processMessage from '@salesforce/apex/AI_AgentController.processMessage';

export default class AiAgentConsole extends LightningElement {

    userMessage = '';
    isLoading = false;
    errorMessage = '';

    messages = [];

    connectedCallback() {
        this.addAgentMessage(
            'Hello! I am your Salesforce AI Customer Service Agent. How can I help you?'
        );
    }

    get sendDisabled() {
        return this.isLoading || !this.userMessage.trim();
    }

    get hasMessages() {
        return this.messages.length > 0;
    }

    handleMessageChange(event) {
        this.userMessage = event.target.value;
    }

    async handleSend() {

        const message = this.userMessage.trim();

        if (!message || this.isLoading) {
            return;
        }

        this.errorMessage = '';

        this.addUserMessage(message);

        this.userMessage = '';

        this.isLoading = true;

        try {

            const response = await processMessage({
                userMessage: message
            });

            this.handleAgentResponse(response);

        } catch (error) {

            this.handleError(error);

        } finally {

            this.isLoading = false;

            this.scrollToBottom();
        }
    }

    handleKeyDown(event) {

        if (event.key === 'Enter' && !event.shiftKey) {

            event.preventDefault();

            if (!this.sendDisabled) {
                this.handleSend();
            }
        }
    }

    handleAgentResponse(response) {

        if (!response) {

            this.addAgentMessage(
                'I did not receive a response from the Agent.'
            );

            return;
        }

        if (response.success) {

            this.addAgentMessage(
                response.message,
                response
            );

        } else if (response.approvalRequired) {

            this.addAgentMessage(
                response.message ||
                'This action requires approval before it can be executed.',
                response
            );

        } else {

            this.addAgentMessage(
                response.message ||
                'I could not complete the request.',
                response
            );
        }
    }

    handleError(error) {

        const message = this.normalizeError(error);

        this.errorMessage = message;

        this.addAgentMessage(
            'I encountered an error while processing your request.'
        );
    }

    normalizeError(error) {

        if (error?.body?.message) {
            return error.body.message;
        }

        if (error?.message) {
            return error.message;
        }

        return 'Unexpected error while contacting the Agent.';
    }

    addUserMessage(message) {

        this.messages = [
            ...this.messages,
            {
                id: this.createMessageId(),
                type: 'user',
                text: message,
                isUser: true,
                isAgent: false
            }
        ];
    }

    addAgentMessage(message, response = null) {

        this.messages = [
            ...this.messages,
            {
                id: this.createMessageId(),
                type: 'agent',
                text: message,
                isUser: false,
                isAgent: true,

                intent: response?.intent || null,
                selectedTool: response?.selectedTool || null,
                approvalRequired:
                    response?.approvalRequired || false,

                toolData: response?.toolData || null,

                hasMetadata:
                    !!response?.intent ||
                    !!response?.selectedTool,

                hasToolData:
                    !!response?.toolData
            }
        ];
    }

    createMessageId() {

        return `${Date.now()}-${Math.random()
            .toString(36)
            .substring(2, 9)}`;
    }

    clearConversation() {

        this.messages = [];

        this.errorMessage = '';

        this.userMessage = '';

        this.addAgentMessage(
            'Conversation cleared. How can I help you?'
        );
    }

    scrollToBottom() {

        window.clearTimeout(this.scrollTimer);

        this.scrollTimer = window.setTimeout(() => {

            const container =
                this.template.querySelector(
                    '.chat-container'
                );

            if (container) {

                container.scrollTop =
                    container.scrollHeight;
            }

        }, 50);
    }
}