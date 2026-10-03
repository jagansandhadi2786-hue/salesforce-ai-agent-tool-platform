import { LightningElement } from 'lwc';

import processMessage
    from '@salesforce/apex/AI_AgentController.processMessage';


const MAX_MESSAGE_LENGTH = 4000;


export default class AiAgentConsole extends LightningElement {

    messages = [];

    inputMessage = '';

    isLoading = false;Cl

    errorMessage = '';

    sessionId;


    connectedCallback() {

        this.sessionId =
            this.generateSessionId();


        this.addMessage(
            'assistant',
            'Hello! How can I help you today?'
        );
    }


    generateSessionId() {

        const randomPart =
            Math.random()
                .toString(36)
                .substring(2, 10)
                .toUpperCase();


        return `AGENT-${randomPart}`;
    }


    get hasMessages() {

        return this.messages.length > 0;
    }


    get sendDisabled() {

        return (
            this.isLoading ||
            !this.inputMessage.trim()
        );
    }


    get hasError() {

        return !!this.errorMessage;
    }


    get formattedSessionId() {

        return this.sessionId || 'Starting...';
    }


    handleInput(event) {

        this.inputMessage =
            event.target.value;


        if (this.errorMessage) {

            this.errorMessage = '';
        }
    }


    handleKeyDown(event) {

        /*
         * Enter = Send
         * Shift + Enter = New line
         */

        if (
            event.key === 'Enter' &&
            !event.shiftKey
        ) {

            event.preventDefault();

            this.handleSend();
        }
    }


    async handleSend() {

        if (this.sendDisabled) {

            return;
        }


        const userMessage =
            this.inputMessage.trim();


        if (!userMessage) {

            return;
        }


        if (
            userMessage.length >
            MAX_MESSAGE_LENGTH
        ) {

            this.errorMessage =
                `Message cannot exceed ${MAX_MESSAGE_LENGTH} characters.`;

            return;
        }


        this.errorMessage = '';


        /*
         * Add user message immediately.
         */

        this.addMessage(
            'user',
            userMessage
        );


        this.inputMessage = '';

        this.isLoading = true;


        try {

            const request = {
                sessionId:
                    this.sessionId,

                userMessage:
                    userMessage
            };


            const response =
                await processMessage({
                    request: request
                });


            this.handleAgentResponse(
                response
            );

        } catch (error) {

            this.handleError(
                error
            );

        } finally {

            this.isLoading = false;
        }
    }


    handleAgentResponse(
        response
    ) {

        if (!response) {

            this.errorMessage =
                'The AI agent returned no response.';

            return;
        }


        if (
            response.success !== true
        ) {

            this.errorMessage =
                response.errorMessage ||
                'The AI agent could not complete the request.';


            this.addMessage(
                'assistant',
                'I could not complete that request.'
            );

            return;
        }


        const message =
            response.message ||
            'The agent completed the request.';


        this.addMessage(
            'assistant',
            message,
            response
        );
    }


    handleError(
        error
    ) {

        console.error(
            'AI Agent error',
            error
        );


        let message =
            'An unexpected error occurred.';


        if (
            error &&
            error.body &&
            error.body.message
        ) {

            message =
                error.body.message;
        }


        this.errorMessage =
            message;


        this.addMessage(
            'assistant',
            'I encountered an error while processing your request.'
        );
    }


    addMessage(
        role,
        text,
        response
    ) {

        const message = {

            id:
                `${Date.now()}-${Math.random()}`,

            role:
                role,

            text:
                text,

            isUser:
                role === 'user',

            isAssistant:
                role === 'assistant',

            cssClass:
                role === 'user'
                    ? 'message-wrapper user-message'
                    : 'message-wrapper assistant-message',

            intent:
                response
                    ? response.intent
                    : null,

            selectedTool:
                response
                    ? response.selectedTool
                    : null,

            approvalRequired:
                response
                    ? response.approvalRequired === true
                    : false
        };


        this.messages = [
            ...this.messages,
            message
        ];


        this.scrollToBottom();
    }


    clearConversation() {

        this.messages = [];

        this.errorMessage = '';

        this.sessionId = this.generateSessionId();

        this.addMessage(
            'assistant',
            'Hello! How can I help you today?'
        );
    }
    
    clearError() {

        this.errorMessage = '';
}

    scrollToBottom() {

    window.setTimeout(() => {

        const container =
            this.template.querySelector(
                '.messages-container'
            );


        if (container) {

            container.scrollTop =
                container.scrollHeight;
        }

    }, 0);
}

    scrollToBottom() {

        window.setTimeout(() => {

            const container =
                this.template.querySelector(
                    '.messages-container'
                );


            if (container) {

                container.scrollTop =
                    container.scrollHeight;
            }

        }, 0);
    }
    
}
