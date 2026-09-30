import processMessage from '@salesforce/apex/AI_AgentController.processMessage';
export default class AiAgentConsole extends LightningElement {

    userMessage = '';
    responseMessage = '';
    isLoading = false;
    errorMessage = '';

    handleMessageChange(event) {
        this.userMessage = event.target.value;
    }

    async handleSend() {

        if (!this.userMessage || !this.userMessage.trim()) {
            this.errorMessage = 'Please enter a message.';
            return;
        }

        this.isLoading = true;
        this.errorMessage = '';
        this.responseMessage = '';

        try {

            const response =
                await processMessage({
                    userMessage: this.userMessage
                });

            if (response && response.success) {

                this.responseMessage =
                    response.message;

            } else {

                this.errorMessage =
                    response?.message ||
                    'The Agent could not process the request.';
            }

        } catch (error) {

            this.errorMessage =
                this.normalizeError(error);

        } finally {

            this.isLoading = false;
        }
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
}