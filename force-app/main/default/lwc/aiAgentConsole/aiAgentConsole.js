import { LightningElement } from 'lwc';

import processMessage
    from '@salesforce/apex/AI_AgentController.processMessage';


const MAX_MESSAGE_LENGTH = 4000;


export default class AiAgentConsole extends LightningElement {

    // ============================================================
    // Conversation state
    // ============================================================

    messages = [];

    inputMessage = '';

    isLoading = false;

    errorMessage = '';

    sessionId;


    // ============================================================
    // Agent metadata
    // ============================================================

    agentStatus = 'Online';

    currentIntent;

    executionStatus;

    toolExecutions = [];

    totalExecutionTime;


    // ============================================================
    // Component initialization
    // ============================================================

    connectedCallback() {

        this.sessionId =
            this.generateSessionId();

        this.agentStatus =
            'Online';

        this.addMessage(
            'assistant',
            'Hello! How can I help you today?'
        );
    }


    // ============================================================
    // Generate session ID
    // ============================================================

    generateSessionId() {

        const randomPart =
            Math.random()
                .toString(36)
                .substring(2, 10)
                .toUpperCase();

        return `AGENT-${randomPart}`;
    }


    // ============================================================
    // Getters
    // ============================================================

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


    // ============================================================
    // Computed UI properties
    // ============================================================

    get hasToolExecutions() {

        return (
            this.toolExecutions &&
            this.toolExecutions.length > 0
        );
    }


    get hasIntent() {

        return !!this.currentIntent;
    }


    get agentStatusLabel() {

        return this.agentStatus || 'Offline';
    }


    get agentStatusClass() {

        if (
            this.agentStatus === 'Error'
        ) {

            return 'status-indicator error';
        }


        if (
            this.agentStatus === 'Processing'
        ) {

            return 'status-indicator processing';
        }


        return 'status-indicator online';
    }


    // ============================================================
    // Input handling
    // ============================================================

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


    // ============================================================
    // Send message to Apex
    // ============================================================

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


        // --------------------------------------------------------
        // Start processing
        // --------------------------------------------------------

        this.errorMessage = '';

        this.agentStatus =
            'Processing';


        // --------------------------------------------------------
        // Reset metadata for new execution
        // --------------------------------------------------------

        this.currentIntent = null;

        this.executionStatus = null;

        this.toolExecutions = [];

        this.totalExecutionTime = null;


        // --------------------------------------------------------
        // Add user message immediately
        // --------------------------------------------------------

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


            /*
             * Return to Online after successful processing.
             * Do not overwrite Error status.
             */

            if (
                this.agentStatus !== 'Error'
            ) {

                this.agentStatus =
                    'Online';
            }
        }
    }


    // ============================================================
    // Handle structured AI Agent response
    // ============================================================

    handleAgentResponse(response) {

        if (!response) {

            this.errorMessage =
                'The AI agent returned no response.';

            this.agentStatus =
                'Error';

            this.executionStatus =
                'ERROR';

            return;
        }


        // --------------------------------------------------------
        // Agent status
        // --------------------------------------------------------

        this.agentStatus =
            response.agentStatus ||
            'Online';


        // --------------------------------------------------------
        // Intent
        // --------------------------------------------------------

        this.currentIntent =
            response.intent ||
            null;


        // --------------------------------------------------------
        // Execution status
        // --------------------------------------------------------

        this.executionStatus =
            response.executionStatus ||
            null;


        // --------------------------------------------------------
        // Tool executions
        // --------------------------------------------------------

        this.toolExecutions =
            response.toolExecutions ||
            [];


        // --------------------------------------------------------
        // Execution time
        // --------------------------------------------------------

        this.totalExecutionTime =
            response.executionTime ||
            null;


        // --------------------------------------------------------
        // Handle unsuccessful response
        // --------------------------------------------------------

        if (
            response.success !== true
        ) {

            this.agentStatus =
                'Error';

            this.errorMessage =
                response.errorMessage ||
                'The AI agent could not complete the request.';


            this.addMessage(
                'assistant',
                'I could not complete that request.',
                response
            );

            return;
        }


        // --------------------------------------------------------
        // Successful response
        // --------------------------------------------------------

        this.errorMessage = '';

        this.addMessage(
            'assistant',
            response.message ||
            'The agent completed the request.',
            response
        );
    }


    // ============================================================
    // Handle Apex / network errors
    // ============================================================

    handleError(error) {

        console.error(
            'AI Agent error',
            error
        );


        this.agentStatus =
            'Error';


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


        this.executionStatus =
            'ERROR';


        this.addMessage(
            'assistant',
            'I encountered an error while processing your request.'
        );
    }


    // ============================================================
    // Add message to conversation
    // ============================================================

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


            // ----------------------------------------------------
            // Existing response metadata
            // ----------------------------------------------------

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
                    : false,


            // ----------------------------------------------------
            // Structured execution metadata
            // ----------------------------------------------------

            agentStatus:
                response
                    ? response.agentStatus
                    : null,

            executionStatus:
                response
                    ? response.executionStatus
                    : null,

            executionTime:
                response
                    ? response.executionTime
                    : null,

            toolExecutions:
                response
                    ? response.toolExecutions || []
                    : []
        };


        this.messages = [

            ...this.messages,

            message
        ];


        this.scrollToBottom();
    }


    // ============================================================
    // Clear conversation
    // ============================================================

    clearConversation() {

        this.messages = [];

        this.errorMessage = '';

        this.agentStatus =
            'Online';

        this.currentIntent =
            null;

        this.executionStatus =
            null;

        this.toolExecutions =
            [];

        this.totalExecutionTime =
            null;

         this.agentStatus = 'Online';    

        this.sessionId =
            this.generateSessionId();


        this.addMessage(
            'assistant',
            'Hello! How can I help you today?'
        );
    }


    // ============================================================
    // Clear error
    // ============================================================

    clearError() {

        this.errorMessage = '';
    }


    // ============================================================
    // Scroll conversation to bottom
    // ============================================================

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