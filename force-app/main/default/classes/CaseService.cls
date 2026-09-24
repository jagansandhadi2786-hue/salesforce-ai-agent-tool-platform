public with sharing class CaseService {
    // getOpenCases()
    // getCaseDetails()
    // createCase()
    // updateCase()
    // createTask()
    // escalateCase()
    // Later, this can become a much more sophisticated business process involving:
    // Case, Escalation Rule, Manager, Notification, Audit


    public static List<Case> getOpenCases(Id accountId) {

        if (accountId == null) {
            throw new AI_ServiceException(
                'Account ID is required.'
            );
        }

        return [
            SELECT
                Id,
                CaseNumber,
                Subject,
                Description,
                Status,
                Priority,
                Origin,
                CreatedDate,
                LastModifiedDate
            FROM Case
            WHERE AccountId = :accountId
            AND IsClosed = false
            WITH USER_MODE
            ORDER BY CreatedDate DESC
            LIMIT 50
        ];
    }


    public static Case getCaseDetails(Id caseId) {

        if (caseId == null) {
            throw new AI_ServiceException(
                'Case ID is required.'
            );
        }

        List<Case> cases = [
            SELECT
                Id,
                CaseNumber,
                AccountId,
                Account.Name,
                ContactId,
                Contact.Name,
                Subject,
                Description,
                Status,
                Priority,
                Origin,
                Reason,
                Type,
                CreatedDate,
                LastModifiedDate
            FROM Case
            WHERE Id = :caseId
            WITH USER_MODE
            LIMIT 1
        ];

        if (cases.isEmpty()) {
            throw new AI_ServiceException(
                'Case was not found or is not accessible.'
            );
        }

        return cases[0];
    }


    public static Case createCase(
        Id accountId,
        String subject,
        String description,
        String priority
    ) {

        if (accountId == null) {
            throw new AI_ServiceException(
                'Account ID is required.'
            );
        }

        if (String.isBlank(subject)) {
            throw new AI_ServiceException(
                'Case subject is required.'
            );
        }

        if (String.isBlank(description)) {
            throw new AI_ServiceException(
                'Case description is required.'
            );
        }

        Set<String> validPriorities = new Set<String>{
            'Low',
            'Medium',
            'High'
        };

        if (String.isBlank(priority)) {
            priority = 'Medium';
        }

        if (!validPriorities.contains(priority)) {
            throw new AI_ServiceException(
                'Invalid priority.'
            );
        }

        Case newCase = new Case(
            AccountId = accountId,
            Subject = subject.trim(),
            Description = description.trim(),
            Priority = priority,
            Origin = 'Web'
        );

        insert as user newCase;

        return newCase;
    }


    public static Case updateCase(
        Id caseId,
        String status,
        String priority,
        String subject
    ) {

        if (caseId == null) {
            throw new AI_ServiceException(
                'Case ID is required.'
            );
        }

        List<Case> cases = [
            SELECT
                Id,
                Subject,
                Status,
                Priority
            FROM Case
            WHERE Id = :caseId
            WITH USER_MODE
            LIMIT 1
        ];

        if (cases.isEmpty()) {
            throw new AI_ServiceException(
                'Case was not found or is not accessible.'
            );
        }

        Case existingCase = cases[0];

        if (!String.isBlank(subject)) {
            existingCase.Subject = subject.trim();
        }

        if (!String.isBlank(status)) {
            existingCase.Status = status;
        }

        if (!String.isBlank(priority)) {

            Set<String> validPriorities = new Set<String>{
                'Low',
                'Medium',
                'High'
            };

            if (!validPriorities.contains(priority)) {
                throw new AI_ServiceException(
                    'Invalid priority.'
                );
            }

            existingCase.Priority = priority;
        }

        update as user existingCase;

        return existingCase;
    }


    public static Task createTask(
        Id whatId,
        String subject,
        Date dueDate
    ) {

        if (whatId == null) {
            throw new AI_ServiceException(
                'Related record ID is required.'
            );
        }

        if (String.isBlank(subject)) {
            throw new AI_ServiceException(
                'Task subject is required.'
            );
        }

        if (dueDate == null) {
            dueDate = Date.today().addDays(1);
        }

        Task taskRecord = new Task(
            WhatId = whatId,
            Subject = subject.trim(),
            ActivityDate = dueDate,
            Status = 'Not Started',
            Priority = 'Normal'
        );

        insert as user taskRecord;

        return taskRecord;
    }


    public static Case escalateCase(Id caseId) {

        if (caseId == null) {
            throw new AI_ServiceException(
                'Case ID is required.'
            );
        }

        List<Case> cases = [
            SELECT
                Id,
                Subject,
                Status,
                Priority
            FROM Case
            WHERE Id = :caseId
            WITH USER_MODE
            LIMIT 1
        ];

        if (cases.isEmpty()) {
            throw new AI_ServiceException(
                'Case was not found or is not accessible.'
            );
        }

        Case caseRecord = cases[0];

        caseRecord.Priority = 'High';

        if (caseRecord.Status == 'New') {
            caseRecord.Status = 'Working';
        }

        update as user caseRecord;

        return caseRecord;
    }
}