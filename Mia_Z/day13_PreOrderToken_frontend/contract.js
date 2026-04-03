(function initPreOrderTokenContractModule() {
  const ABI = [
    "function name() view returns (string)",
    "function symbol() view returns (string)",
    "function decimals() view returns (uint8)",
    "function totalSupply() view returns (uint256)",
    "function balanceOf(address) view returns (uint256)",
    "function tokenPrice() view returns (uint256)",
    "function saleStartTime() view returns (uint256)",
    "function saleEndTime() view returns (uint256)",
    "function minPurchase() view returns (uint256)",
    "function maxPurchase() view returns (uint256)",
    "function totalRaised() view returns (uint256)",
    "function projectOwner() view returns (address)",
    "function finalized() view returns (bool)",
    "function isSaleActive() view returns (bool)",
    "function timeRemaining() view returns (uint256)",
    "function tokensAvailable() view returns (uint256)",
    "function buyTokens() payable",
    "function finalizeSale()",
    "function transfer(address,uint256) returns (bool)",
    "event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount)",
    "event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold)"
  ];

  const METAMASK_DOWNLOAD_URL = "https://metamask.io/download/";
  const state = {
    provider: undefined,
    signer: undefined,
    injectedProvider: undefined,
    readContract: undefined,
    writeContract: undefined,
    contractAddress: "",
    decimals: 18
  };

  function isFileProtocol() {
    return window.location.protocol === "file:";
  }

  function getInjectedProvider() {
    if (window.ethereum?.isMetaMask) return window.ethereum;
    const providers = window.ethereum?.providers;
    if (Array.isArray(providers)) {
      const metamask = providers.find((item) => item?.isMetaMask);
      if (metamask) return metamask;
    }
    return window.ethereum;
  }

  async function waitForProvider(timeoutMs = 1800) {
    const available = getInjectedProvider();
    if (available) return available;
    return new Promise((resolve) => {
      let done = false;
      const tryResolve = () => {
        if (done) return;
        const provider = getInjectedProvider();
        if (!provider) return;
        done = true;
        window.removeEventListener("ethereum#initialized", tryResolve);
        resolve(provider);
      };
      window.addEventListener("ethereum#initialized", tryResolve, { once: true });
      const timer = window.setInterval(tryResolve, 100);
      window.setTimeout(() => {
        window.clearInterval(timer);
        if (done) return;
        done = true;
        window.removeEventListener("ethereum#initialized", tryResolve);
        resolve(undefined);
      }, timeoutMs);
    });
  }

  function ensureAddress(address, fieldLabel) {
    if (!ethers.isAddress(address)) {
      throw new Error(`${fieldLabel} 地址格式不正确`);
    }
  }

  function getReadableError(error) {
    if (!error) return "未知错误";
    if (typeof error === "string") return error;
    if (error.code === 4001) return "用户取消了钱包签名";
    return error.shortMessage || error.reason || error.message || "未知错误";
  }

  async function connectWallet() {
    state.injectedProvider = await waitForProvider();
    if (!state.injectedProvider) {
      const fileHint = isFileProtocol() ? "（建议改用 http://localhost 打开页面）" : "";
      throw new Error(`未检测到 MetaMask${fileHint}。请确认扩展已启用，或前往 ${METAMASK_DOWNLOAD_URL}`);
    }
    state.provider = new ethers.BrowserProvider(state.injectedProvider);
    await state.provider.send("eth_requestAccounts", []);
    await syncSignerBindings();
    return getWalletInfo();
  }

  async function syncSignerBindings() {
    if (!state.provider) return;
    state.signer = await state.provider.getSigner();
    if (state.contractAddress) {
      state.readContract = new ethers.Contract(state.contractAddress, ABI, state.provider);
      state.writeContract = new ethers.Contract(state.contractAddress, ABI, state.signer);
    }
  }

  async function getWalletInfo() {
    if (!state.provider) {
      return { connected: false, address: "", chainId: "", networkName: "" };
    }
    await syncSignerBindings();
    const address = await state.signer.getAddress();
    const network = await state.provider.getNetwork();
    return {
      connected: true,
      address,
      chainId: network.chainId.toString(),
      networkName: network.name
    };
  }

  function ensureWalletReady() {
    if (!state.provider || !state.signer) {
      throw new Error("请先连接钱包");
    }
  }

  function ensureContractReady() {
    ensureWalletReady();
    if (!state.readContract || !state.writeContract) {
      throw new Error("请先初始化合约");
    }
  }

  async function initContract(contractAddress) {
    ensureWalletReady();
    const address = contractAddress.trim();
    ensureAddress(address, "合约");
    state.contractAddress = address;
    state.readContract = new ethers.Contract(address, ABI, state.provider);
    state.writeContract = new ethers.Contract(address, ABI, state.signer);
    const meta = await readTokenMeta();
    state.decimals = meta.decimals;
    return meta;
  }

  function formatTokenAmount(value) {
    return ethers.formatUnits(value, state.decimals);
  }

  function formatEther(value) {
    return ethers.formatEther(value);
  }

  function parseEther(ethText) {
    const s = String(ethText).trim();
    if (!s) throw new Error("请输入 ETH 数量");
    return ethers.parseEther(s);
  }

  function parseTokenAmount(amountText) {
    const amount = String(amountText).trim();
    if (!amount) throw new Error("请输入数量");
    const parsed = ethers.parseUnits(amount, state.decimals);
    if (parsed <= 0n) throw new Error("数量必须大于 0");
    return parsed;
  }

  async function readTokenMeta() {
    ensureContractReady();
    const [name, symbol, decimals, totalSupply] = await Promise.all([
      state.readContract.name(),
      state.readContract.symbol(),
      state.readContract.decimals(),
      state.readContract.totalSupply()
    ]);
    state.decimals = Number(decimals);
    return {
      name,
      symbol,
      decimals: state.decimals,
      totalSupplyRaw: totalSupply,
      totalSupplyFormatted: ethers.formatUnits(totalSupply, state.decimals)
    };
  }

  async function readSaleInfo() {
    ensureContractReady();
    const [
      tokenPrice,
      saleStartTime,
      saleEndTime,
      minPurchase,
      maxPurchase,
      totalRaised,
      projectOwner,
      finalized,
      isActive,
      timeRemaining,
      tokensAvailable
    ] = await Promise.all([
      state.readContract.tokenPrice(),
      state.readContract.saleStartTime(),
      state.readContract.saleEndTime(),
      state.readContract.minPurchase(),
      state.readContract.maxPurchase(),
      state.readContract.totalRaised(),
      state.readContract.projectOwner(),
      state.readContract.finalized(),
      state.readContract.isSaleActive(),
      state.readContract.timeRemaining(),
      state.readContract.tokensAvailable()
    ]);
    return {
      tokenPrice,
      saleStartTime,
      saleEndTime,
      minPurchase,
      maxPurchase,
      totalRaised,
      projectOwner,
      finalized,
      isSaleActive: isActive,
      timeRemaining,
      tokensAvailable,
      minPurchaseFormatted: formatEther(minPurchase),
      maxPurchaseFormatted: formatEther(maxPurchase),
      totalRaisedFormatted: formatEther(totalRaised),
      tokenPriceFormatted: formatEther(tokenPrice),
      tokensAvailableFormatted: formatTokenAmount(tokensAvailable)
    };
  }

  async function readBalance(address) {
    ensureContractReady();
    const targetAddress = address || (await state.signer.getAddress());
    ensureAddress(targetAddress, "余额查询");
    const balance = await state.readContract.balanceOf(targetAddress);
    return {
      address: targetAddress,
      balanceRaw: balance,
      balanceFormatted: formatTokenAmount(balance)
    };
  }

  async function buyTokens(ethAmountWei) {
    ensureContractReady();
    const tx = await state.writeContract.buyTokens({ value: ethAmountWei });
    return { hash: tx.hash, wait: () => tx.wait() };
  }

  async function finalizeSale() {
    ensureContractReady();
    const tx = await state.writeContract.finalizeSale();
    return { hash: tx.hash, wait: () => tx.wait() };
  }

  async function transferTokens(to, amountText) {
    ensureContractReady();
    ensureAddress(to.trim(), "transfer 接收方");
    const amount = parseTokenAmount(amountText);
    const tx = await state.writeContract.transfer(to.trim(), amount);
    return { hash: tx.hash, wait: () => tx.wait() };
  }

  function resetContract() {
    state.readContract = undefined;
    state.writeContract = undefined;
    state.contractAddress = "";
  }

  function onAccountsChanged(handler) {
    const injected = state.injectedProvider || getInjectedProvider();
    if (!injected?.on) return;
    injected.on("accountsChanged", handler);
  }

  function onChainChanged(handler) {
    const injected = state.injectedProvider || getInjectedProvider();
    if (!injected?.on) return;
    injected.on("chainChanged", handler);
  }

  function getStateSnapshot() {
    return {
      contractAddress: state.contractAddress,
      decimals: state.decimals,
      isWalletConnected: Boolean(state.provider && state.signer),
      isContractReady: Boolean(state.readContract && state.writeContract)
    };
  }

  window.PreOrderTokenContract = {
    ABI,
    METAMASK_DOWNLOAD_URL,
    isFileProtocol,
    getReadableError,
    connectWallet,
    getWalletInfo,
    initContract,
    readTokenMeta,
    readSaleInfo,
    readBalance,
    buyTokens,
    finalizeSale,
    transferTokens,
    formatEther,
    formatTokenAmount,
    parseEther,
    resetContract,
    onAccountsChanged,
    onChainChanged,
    getStateSnapshot
  };
})();
