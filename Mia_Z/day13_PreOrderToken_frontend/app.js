(function initApp() {
  const contractApi = window.PreOrderTokenContract;
  let providerEventsBound = false;

  const els = {
    status: document.getElementById("status"),
    walletInfo: document.getElementById("walletInfo"),
    contractAddress: document.getElementById("contractAddress"),
    contractInfo: document.getElementById("contractInfo"),
    tokenName: document.getElementById("tokenName"),
    tokenSymbol: document.getElementById("tokenSymbol"),
    tokenSupply: document.getElementById("tokenSupply"),
    saleActive: document.getElementById("saleActive"),
    tokenPrice: document.getElementById("tokenPrice"),
    minMaxPurchase: document.getElementById("minMaxPurchase"),
    timeRemaining: document.getElementById("timeRemaining"),
    tokensAvailable: document.getElementById("tokensAvailable"),
    totalRaisedAndFinalized: document.getElementById("totalRaisedAndFinalized"),
    myBalance: document.getElementById("myBalance"),
    currentAccount: document.getElementById("currentAccount"),
    buyEthAmount: document.getElementById("buyEthAmount"),
    transferTo: document.getElementById("transferTo"),
    transferAmount: document.getElementById("transferAmount"),
    lastTxHash: document.getElementById("lastTxHash"),
    connectBtn: document.getElementById("connectBtn"),
    refreshWalletBtn: document.getElementById("refreshWalletBtn"),
    initContractBtn: document.getElementById("initContractBtn"),
    refreshSaleBtn: document.getElementById("refreshSaleBtn"),
    refreshBalanceBtn: document.getElementById("refreshBalanceBtn"),
    buyTokensBtn: document.getElementById("buyTokensBtn"),
    finalizeSaleBtn: document.getElementById("finalizeSaleBtn"),
    transferBtn: document.getElementById("transferBtn")
  };

  function setStatus(message, type) {
    els.status.textContent = "状态：" + message;
    els.status.classList.remove("success", "error");
    if (type === "success") els.status.classList.add("success");
    if (type === "error") els.status.classList.add("error");
  }

  function setContractReadyLabel(isReady, address) {
    els.contractInfo.textContent = isReady ? "合约已初始化: " + (address || "").slice(0, 10) + "..." : "未初始化";
  }

  function setWalletInfoLabel(wallet) {
    if (!wallet.connected) {
      els.walletInfo.textContent = "未连接";
      els.currentAccount.textContent = "-";
      return;
    }
    els.walletInfo.textContent = "地址: " + wallet.address.slice(0, 10) + "... | chainId: " + wallet.chainId;
    els.currentAccount.textContent = wallet.address;
  }

  function renderTokenMeta(meta) {
    els.tokenName.textContent = meta.name;
    els.tokenSymbol.textContent = meta.symbol;
    els.tokenSupply.textContent = meta.totalSupplyFormatted + " " + meta.symbol;
  }

  function renderSaleInfo(sale) {
    els.saleActive.textContent = sale.isSaleActive ? "进行中" : (sale.finalized ? "已结束" : "未开始/已过期");
    els.tokenPrice.textContent = sale.tokenPriceFormatted + " ETH";
    els.minMaxPurchase.textContent = sale.minPurchaseFormatted + " / " + sale.maxPurchaseFormatted + " ETH";
    els.timeRemaining.textContent = String(sale.timeRemaining);
    els.tokensAvailable.textContent = sale.tokensAvailableFormatted + " " + (els.tokenSymbol.textContent !== "-" ? els.tokenSymbol.textContent : "");
    els.totalRaisedAndFinalized.textContent = sale.totalRaisedFormatted + " ETH | finalized: " + (sale.finalized ? "是" : "否");
  }

  function renderBalance(balance, symbolText) {
    const suffix = symbolText || "Token";
    els.myBalance.textContent = balance.balanceFormatted + " " + suffix;
  }

  function setLastTxHash(hash) {
    els.lastTxHash.textContent = hash || "-";
  }

  async function refreshWalletOnly() {
    const wallet = await contractApi.getWalletInfo();
    setWalletInfoLabel(wallet);
    return wallet;
  }

  async function refreshTokenAndSale() {
    const meta = await contractApi.readTokenMeta();
    renderTokenMeta(meta);
    const sale = await contractApi.readSaleInfo();
    renderSaleInfo(sale);
    return { meta, sale };
  }

  async function refreshBalanceSection() {
    const symbolText = els.tokenSymbol.textContent !== "-" ? els.tokenSymbol.textContent : "MTK";
    const balance = await contractApi.readBalance();
    renderBalance(balance, symbolText);
    return balance;
  }

  async function refreshAllReadable() {
    const snapshot = contractApi.getStateSnapshot();
    if (!snapshot.isContractReady) return;
    await refreshTokenAndSale();
    await refreshBalanceSection();
  }

  async function runAction(label, action, options) {
    const shouldRefresh = options?.refresh !== false;
    setStatus(label + " 交易发送中...");
    const result = await action();
    setLastTxHash(result.hash);
    setStatus(label + " 已发送，等待确认... tx: " + result.hash);
    await result.wait();
    setStatus(label + " 已确认，tx: " + result.hash, "success");
    if (shouldRefresh) await refreshAllReadable();
    return result;
  }

  async function handleConnectWallet() {
    setStatus("连接钱包中...");
    const wallet = await contractApi.connectWallet();
    bootstrapProviderEvents();
    setWalletInfoLabel(wallet);
    setStatus("钱包连接成功", "success");
  }

  async function handleInitContract() {
    const meta = await contractApi.initContract(els.contractAddress.value.trim());
    setContractReadyLabel(true, els.contractAddress.value.trim());
    renderTokenMeta(meta);
    await refreshWalletOnly();
    await contractApi.readSaleInfo().then(renderSaleInfo).catch(() => {});
    await refreshBalanceSection();
    setStatus("合约初始化成功", "success");
  }

  async function handleBuyTokens() {
    const ethText = els.buyEthAmount.value.trim();
    if (!ethText) {
      setStatus("请输入要支付的 ETH 数量", "error");
      return;
    }
    const wei = contractApi.parseEther(ethText);
    await runAction("buyTokens", () => contractApi.buyTokens(wei));
  }

  async function handleFinalizeSale() {
    await runAction("finalizeSale", () => contractApi.finalizeSale());
  }

  async function handleTransfer() {
    await runAction("transfer", () =>
      contractApi.transferTokens(els.transferTo.value.trim(), els.transferAmount.value)
    );
  }

  async function handleAccountChanged() {
    try {
      const snapshot = contractApi.getStateSnapshot();
      if (!snapshot.isWalletConnected) return;
      await refreshWalletOnly();
      if (snapshot.isContractReady) await refreshBalanceSection();
      setStatus("检测到账户切换，已刷新", "success");
    } catch (e) {
      setStatus("账户切换处理失败 - " + contractApi.getReadableError(e), "error");
    }
  }

  function handleChainChanged() {
    contractApi.resetContract();
    setContractReadyLabel(false, "");
    els.tokenName.textContent = "-";
    els.tokenSymbol.textContent = "-";
    els.tokenSupply.textContent = "-";
    els.saleActive.textContent = "-";
    els.tokenPrice.textContent = "-";
    els.minMaxPurchase.textContent = "-";
    els.timeRemaining.textContent = "-";
    els.tokensAvailable.textContent = "-";
    els.totalRaisedAndFinalized.textContent = "-";
    els.myBalance.textContent = "-";
    setStatus("检测到网络切换，请重新初始化合约", "error");
  }

  function bindEvents() {
    els.connectBtn.addEventListener("click", async () => {
      try {
        await handleConnectWallet();
      } catch (e) {
        setStatus("连接失败 - " + contractApi.getReadableError(e), "error");
      }
    });

    els.refreshWalletBtn.addEventListener("click", async () => {
      try {
        await refreshWalletOnly();
        setStatus("钱包信息已刷新", "success");
      } catch (e) {
        setStatus("刷新失败 - " + contractApi.getReadableError(e), "error");
      }
    });

    els.initContractBtn.addEventListener("click", async () => {
      try {
        await handleInitContract();
      } catch (e) {
        setStatus("初始化失败 - " + contractApi.getReadableError(e), "error");
      }
    });

    els.refreshSaleBtn.addEventListener("click", async () => {
      try {
        await refreshTokenAndSale();
        await refreshBalanceSection();
        setStatus("销售与代币信息已刷新", "success");
      } catch (e) {
        setStatus("刷新失败 - " + contractApi.getReadableError(e), "error");
      }
    });

    els.refreshBalanceBtn.addEventListener("click", async () => {
      try {
        await refreshBalanceSection();
        setStatus("余额已刷新", "success");
      } catch (e) {
        setStatus("刷新失败 - " + contractApi.getReadableError(e), "error");
      }
    });

    els.buyTokensBtn.addEventListener("click", async () => {
      try {
        await handleBuyTokens();
      } catch (e) {
        setStatus("buyTokens 失败 - " + contractApi.getReadableError(e), "error");
      }
    });

    els.finalizeSaleBtn.addEventListener("click", async () => {
      try {
        await handleFinalizeSale();
      } catch (e) {
        setStatus("finalizeSale 失败 - " + contractApi.getReadableError(e), "error");
      }
    });

    els.transferBtn.addEventListener("click", async () => {
      try {
        await handleTransfer();
      } catch (e) {
        setStatus("transfer 失败 - " + contractApi.getReadableError(e), "error");
      }
    });
  }

  function bootstrapProviderEvents() {
    if (providerEventsBound) return;
    contractApi.onAccountsChanged(handleAccountChanged);
    contractApi.onChainChanged(handleChainChanged);
    providerEventsBound = true;
  }

  bindEvents();
  bootstrapProviderEvents();

  if (contractApi.isFileProtocol()) {
    setStatus("当前为 file:// 访问，建议使用 http://localhost 以确保钱包注入");
  }
})();
