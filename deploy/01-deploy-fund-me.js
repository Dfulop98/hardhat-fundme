// hardhat deploy run this func automatically, anonymus function is enough
// hre = hardhat running environment
// hre.getNamedAccounts()
// hre.deployments()

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
};
