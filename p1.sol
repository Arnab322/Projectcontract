// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract ExamCertification {
    address public owner;
    uint256 public passScore;

    // Struct to represent an exam
    struct Exam {
        string[] questions;
        string[] answers;
        uint256 totalQuestions;
    }

    // Struct to represent a student’s exam submission
    struct Submission {
        string[] answers;
        bool isCertified;
        uint256 score;
    }

    // Mapping from student address to their exam submissions
    mapping(address => Submission) public submissions;

    // Mapping from an exam ID to the exam details
    mapping(uint256 => Exam) public exams;

    // Events
    event ExamCreated(uint256 examId, string[] questions);
    event ExamSubmitted(address student, uint256 examId, uint256 score, bool isCertified);

    // Constructor to set the contract owner and pass score threshold
    constructor(uint256 _passScore) {
        owner = msg.sender;
        passScore = _passScore;
    }

    // Modifier to restrict access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Function to create a new exam
    function createExam(uint256 examId, string[] memory questions, string[] memory answers) public onlyOwner {
        exams[examId] = Exam({
            questions: questions,
            answers: answers,
            totalQuestions: questions.length
        });

        emit ExamCreated(examId, questions);
    }

    // Function to submit an exam
    function submitExam(uint256 examId, string[] memory studentAnswers) public {
        require(studentAnswers.length == exams[examId].totalQuestions, "Answer length mismatch");

        uint256 score = 0;

        for (uint256 i = 0; i < studentAnswers.length; i++) {
            if (keccak256(abi.encodePacked(studentAnswers[i])) == keccak256(abi.encodePacked(exams[examId].answers[i]))) {
                score++;
            }
        }

        bool isCertified = score >= passScore;
        submissions[msg.sender] = Submission({
            answers: studentAnswers,
            isCertified: isCertified,
            score: score
        });

        emit ExamSubmitted(msg.sender, examId, score, isCertified);
    }

    // Function to get a student's submission
    function getSubmission() public view returns (Submission memory) {
        return submissions[msg.sender];
    }

    // Function to update the pass score threshold
    function updatePassScore(uint256 newPassScore) public onlyOwner {
        passScore = newPassScore;
    }
}
