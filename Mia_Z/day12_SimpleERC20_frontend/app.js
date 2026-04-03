(function initApp() {
  const contractApi = window.SimpleERC20Contract;
  let providerEventsBound = false;

  const els = {
    status: document.getElementById("status"),
    walletInfo: document.getElementById("walletInfo"),
    contractAddress: document.getElementById("contractAddress"),
    contractInfo: document.getElementById("contractInfo"),
    tokenName: document.getElementById("tokenName"),
    tokenSymbol: document.getElementById("tokenSymbol"),
    tokenDecimals: document.getElementById("tokenDecimals"),
    tokenSupply: document.getElementById("tokenSupply"),
    myBalance: document.getElementById("myBalance"),
    currentAccount: document.getElementById("currentAccount"),
    transferTo: document.getElementById("transferTo"),
    transferAmount: document.getElementById("transferAmount"),
    approveSpender: document.getElementById("approveSpender"),
    approveAmount: document.getElementById("approveAmount"),
    allowanceOwner: document.getElementById("allowanceOwner"),
    allowanceSpender: document.getElementById("allowanceSpender"),
    allowanceResult: document.getElementById("allowanceResult"),
    transferFromOwner: document.getElementById("transferFromOwner"),
    transferFromTo: document.getElementById("transferFromTo"),
    transferFromAmount: document.getElementById("transferFromAmount"),
    lastTxHash: document.getElementById("lastTxHash"),
    connectBtn: document.getElementById("connectBtn"),
    refreshWalletBtn: document.getElementById("refreshWalletBtn"),
    initContractBtn: document.getElementById("initContractBtn"),
    refreshTokenBtn: document.getElementById("refreshTokenBtn"),
    refreshBalanceBtn: document.getElementById("refreshBalanceBtn"),
    transferBtn: document.getElementById("transferBtn"),
    approveBtn: document.getElementById("approveBtn"),
    checkAllowanceBtn: document.getElementById("checkAllowanceBtn"),
    transferFromBtn: document.getElementById("transferFromBtn")
  };

  function setStatus(message, type) {
    els.status.textContent = `状态：${message}`;
    els.status.classList.remove("success", "error");
    if (type === "success") els.status.classList.add("success");
    if (type === "error") els.status.classList.add("error");
  }

  function setContractReadyLabel(isReady, address) {
    els.contractInfo.textContent = isReady ? `合约已初始化: ${address}` : "未初始化";
  }

  function setWalletInfoLabel(wallet) {
    if (!wallet.connected) {
      els.walletInfo.textContent = "未连接";
      els.currentAccount.textContent = "-";
      return;
    }

    els.walletInfo.textContent = `地址: ${wallet.address} | chainId: ${wallet.chainId} | network: ${wallet.networkName}`;
    els.currentAccount.textContent = wallet.address;
  }

  function renderTokenMeta(meta) {
    els.tokenName.textContent = meta.name;
    els.tokenSymbol.textContent = meta.symbol;
    els.tokenDecimals.textContent = String(meta.decimals);
    els.tokenSupply.textContent = `${meta.totalSupplyFormatted} ${meta.symbol}`;
  }

  function renderBalance(balance, symbolText) {
    const suffix = symbolText || "Token";
    els.myBalance.textContent = `${balance.balanceFormatted} ${suffix}`;
  }

  function setLastTxHash(hash) {
    els.lastTxHash.textContent = hash || "-";
  }

  async function refreshWalletOnly() {
    const wallet = await contractApi.getWalletInfo();
    setWalletInfoLabel(wallet);
    if (wallet.connected && !els.allowanceOwner.value.trim()) {
      els.allowanceOwner.value = wallet.address;
    }
    if (wallet.connected && !els.transferFromOwner.value.trim()) {
      els.transferFromOwner.value = wallet.address;
    }
    return wallet;
  }

  async function refreshTokenSection() {
    const meta = await contractApi.readTokenMeta();
    renderTokenMeta(meta);
    return meta;
  }

  async function refreshBalanceSection() {
    const metaSymbol = els.tokenSymbol.textContent !== "-" ? els.tokenSymbol.textContent : "SIM";
    const balance = await contractApi.readBalance();
    renderBalance(balance, metaSymbol);
    return balance;
  }

  async function refreshAllowanceSection() {
    const owner = els.allowanceOwner.value.trim();
    const spender = els.allowanceSpender.value.trim();
    if (!owner || !spender) {
      return null;
    }

    const result = await contractApi.readAllowance(owner, spender);
    els.allowanceResult.textContent = `allowance: ${result.allowanceFormatted}`;
    return result;
  }

  async function refreshAllReadableData() {
    const snapshot = contractApi.getStateSnapshot();
    if (!snapshot.isContractReady) return;
    await refreshTokenSection();
    await refreshBalanceSection();
    await refreshAllowanceSection();
  }

  async function runAction(label, action, options) {
    const shouldRefresh = options?.refresh !== false;
    setStatus(`${label} 交易发送中...`);

    const result = await action();
    setLastTxHash(result.hash);
    setStatus(`${label} 已发送，等待链上确认... tx: ${result.hash}`);
    await result.wait();
    setStatus(`${label} 已确认，tx: ${result.hash}`, "success");

    if (shouldRefresh) {
      await refreshAllReadableData();
    }

    return result;
  }

  async function handleConnectWallet() {
    setStatus("连接钱包中...");
    const wallet = await contractApi.connectWallet();
    bootstrapProviderEvents();
    setWalletInfoLabel(wallet);
    if (!els.allowanceOwner.value.trim()) {
      els.allowanceOwner.value = wallet.address;
    }
    if (!els.transferFromOwner.value.trim()) {
      els.transferFromOwner.value = wallet.address;
    }
    setStatus("钱包连接成功", "success");
  }

  async function handleInitContract() {
    const meta = await contractApi.initContract(els.contractAddress.value);
    setContractReadyLabel(true, els.contractAddress.value.trim());
    renderTokenMeta(meta);
    await refreshWalletOnly();
    await refreshBalanceSection();
    setStatus("合约初始化成功", "success");
  }

  async function handleTransfer() {
    await runAction("transfer", () => contractApi.transferTokens(els.transferTo.value, els.transferAmount.value));
  }

  async function handleApprove() {
    const spender = els.approveSpender.value.trim();
    els.allowanceOwner.value = els.currentAccount.textContent !== "-" ? els.currentAccount.textContent : els.allowanceOwner.value;
    els.allowanceSpender.value = spender;

    await runAction("approve", () => contractApi.approveSpender(spender, els.approveAmount.value));
    await refreshAllowanceSection();
  }

  async function handleCheckAllowance() {
    await refreshAllowanceSection();
    setStatus("allowance 读取成功", "success");
  }

  async function handleTransferFrom() {
    const from = els.transferFromOwner.value.trim();
    els.allowanceOwner.value = from;

    const wallet = await contractApi.getWalletInfo();
    if (wallet.connected) {
      els.allowanceSpender.value = wallet.address;
    }

    await runAction("transferFrom", () =>
      contractApi.transferFromOwner(from, els.transferFromTo.value, els.transferFromAmount.value)
    );
    await refreshAllowanceSection();
  }

  async function handleAccountChanged() {
    try {
      const snapshot = contractApi.getStateSnapshot();
      if (!snapshot.isWalletConnected) return;
      await refreshWalletOnly();
      if (snapshot.isContractReady) {
        await refreshBalanceSection();
      }
      setStatus("检测到账户切换，已刷新钱包与余额", "success");
    } catch (error) {
      setStatus(`账户切换处理失败 - ${contractApi.getReadableError(error)}`, "error");
    }
  }

  function handleChainChanged() {
    contractApi.resetContract();
    setContractReadyLabel(false, "");
    els.tokenName.textContent = "-";
    els.tokenSymbol.textContent = "-";
    els.tokenDecimals.textContent = "-";
    els.tokenSupply.textContent = "-";
    els.myBalance.textContent = "-";
    els.allowanceResult.textContent = "allowance: -";
    setStatus("检测到网络切换，请重新初始化合约", "error");
  }

  function bindEvents() {
    els.connectBtn.addEventListener("click", async () => {
      try {
        await handleConnectWallet();
      } catch (error) {
        setStatus(`连接失败 - ${contractApi.getReadableError(error)}`, "error");
      }
    });

    els.refreshWalletBtn.addEventListener("click", async () => {
      try {
        await refreshWalletOnly();
        setStatus("钱包信息已刷新", "success");
      } catch (error) {
        setStatus(`刷新失败 - ${contractApi.getReadableError(error)}`, "error");
      }
    });

    els.initContractBtn.addEventListener("click", async () => {
      try {
        await handleInitContract();
      } catch (error) {
        setStatus(`初始化失败 - ${contractApi.getReadableError(error)}`, "error");
      }
    });

    els.refreshTokenBtn.addEventListener("click", async () => {
      try {
        await refreshTokenSection();
        setStatus("代币信息已刷新", "success");
      } catch (error) {
        setStatus(`刷新失败 - ${contractApi.getReadableError(error)}`, "error");
      }
    });

    els.refreshBalanceBtn.addEventListener("click", async () => {
      try {
        await refreshBalanceSection();
        setStatus("余额已刷新", "success");
      } catch (error) {
        setStatus(`刷新失败 - ${contractApi.getReadableError(error)}`, "error");
      }
    });

    els.transferBtn.addEventListener("click", async () => {
      try {
        await handleTransfer();
      } catch (error) {
        setStatus(`transfer 失败 - ${contractApi.getReadableError(error)}`, "error");
      }
    });

    els.approveBtn.addEventListener("click", async () => {
      try {
        await handleApprove();
      } catch (error) {
        setStatus(`approve 失败 - ${contractApi.getReadableError(error)}`, "error");
      }
    });

    els.checkAllowanceBtn.addEventListener("click", async () => {
      try {
        await handleCheckAllowance();
      } catch (error) {
        setStatus(`allowance 查询失败 - ${contractApi.getReadableError(error)}`, "error");
      }
    });

    els.transferFromBtn.addEventListener("click", async () => {
      try {
        await handleTransferFrom();
      } catch (error) {
        setStatus(`transferFrom 失败 - ${contractApi.getReadableError(error)}`, "error");
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
    setStatus("当前是 file:// 访问，建议改为 http://localhost 以确保钱包注入稳定");
  }
})();
