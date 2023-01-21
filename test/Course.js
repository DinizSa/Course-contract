const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("", function() {
    let courseContract
    const courseName = "Solidity";
    const courseRegistrationFee = BigInt(10e18);

    beforeEach(async() => {
        [owner, alice, otherAccounts] = await ethers.getSigners();

        const CourseFactory = await ethers.getContractFactory("Course");
        courseContract = await CourseFactory.deploy(courseName, courseRegistrationFee);
    })

    describe('Initialization', () => {
        it('Should set data correctly', async() => {
            expect(await courseContract.name()).to.be.equal(courseName);
            expect(await courseContract.registrationFee()).to.be.equal(courseRegistrationFee);
        })
    })

    describe('register()', () => {
        it('Should properly register student and transfer entry fee', async() => {
            let student = await courseContract.students(alice.address);
            expect(student.isRegistered).to.be.equal(false);

            await courseContract.connect(alice).register("alice", {value: courseRegistrationFee})
            student = await courseContract.students(alice.address);

            expect(student.name).to.be.equal("alice");
            expect(student.totalScore).to.be.equal(0);
            expect(student.isRegistered).to.be.equal(true);
            
            const grades = await courseContract.connect(alice).getGrades(alice.address);
            expect(grades.length).to.be.equal(0);
            
            expect(await ethers.provider.getBalance(courseContract.address)).to.be.equal(courseRegistrationFee);
        })
    })

    describe('addGrades()', () => {
        it('Should properly add grades', async() => {
            const grades = [13, 15, 16];
            await courseContract.connect(owner).addGrades(alice.address, grades);
            student = await courseContract.students(alice.address);

            const gradesStored = await courseContract.connect(alice).getGrades(alice.address);
            expect(gradesStored).to.be.eql(grades);
        })
    })

    describe('getFinalScore()', () => {
        it('Should return correct grades median', async() => {
            const grades = [390, 975, 516];
            await courseContract.connect(owner).addGrades(alice.address, grades);
            student = await courseContract.students(alice.address);
            
            await courseContract.connect(owner).closeCourse();

            const median = Math.floor(grades.reduce((previous, current)=>previous += current) / grades.length);
            const finalScore = await courseContract.connect(alice).getFinalScore(alice.address);
            expect(finalScore).to.be.equal(median);
        })
    })

    describe('withdraw()', () => {
        it('Owner should be able to withdraw funds', async() => {
            await courseContract.connect(alice).register("alice", {value: courseRegistrationFee});
            expect(await ethers.provider.getBalance(courseContract.address)).to.be.equal(courseRegistrationFee);
            
            await courseContract.connect(owner).withdraw(courseRegistrationFee);
            expect(await ethers.provider.getBalance(courseContract.address)).to.be.equal(0);
        })

        it('Not owner should not be able to withdraw funds', async() => {
            await courseContract.connect(alice).register("alice", {value: courseRegistrationFee});
            expect(await ethers.provider.getBalance(courseContract.address)).to.be.equal(courseRegistrationFee);
            
            await expect(courseContract.connect(alice).withdraw(courseRegistrationFee)).to.revertedWith("Not authorized");
            expect(await ethers.provider.getBalance(courseContract.address)).to.be.equal(courseRegistrationFee);
        })
    })
})
