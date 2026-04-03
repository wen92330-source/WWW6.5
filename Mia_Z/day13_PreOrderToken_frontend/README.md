# Day13 PreOrderToken 前端学习面板

与 day12 类似的单页 DApp，用于配合 **PreOrderToken** 合约做预售代币的演示与测试。

## 功能概览

- 连接 MetaMask，输入已部署的 PreOrderToken 合约地址并初始化
- 查看代币信息（name、symbol、总供应量）与销售信息（单价、最小/最大购买、剩余时间、剩余可售、是否进行中、是否已结束）
- 查看当前账户代币余额
- 用 ETH 购买代币（`buyTokens`，需在销售期内且金额在 min/max 之间）
- 项目方结束销售（`finalizeSale`，仅 projectOwner，且需在 saleEndTime 之后）
- 销售结束后进行代币转账（`transfer`）

## 本地运行

用静态服务器打开本目录，例如：

```bash
# 若已安装 Node
npx serve .

# 或 Python
python -m http.server 8080
```

浏览器访问 `http://localhost:8080`（或对应端口），确保 MetaMask 与页面在同一网络。

## Remix 编译与部署

1. 打开 [Remix](https://remix.ethereum.org)。
2. 在文件管理器中放入或粘贴：
   - `day12_SimpleERC20_OpenZeppelin.sol`（依赖 OpenZeppelin，需能解析 `@openzeppelin/contracts`，或用 Remix 的 NPM 插件）
   - `day13_PreOrderToken.sol`
3. 选择 **Solidity 0.8.x** 编译器，点击 **Compile**，确保无报错。
4. 切换到 **Deploy**：
   - Environment 选 **Injected Provider**（MetaMask）或 **Remix VM**。
   - 构造函数示例：
     - `_intitialSupply`: 1000
     - `_tokenPrice`: 1000000000000000（即 0.001 ETH，1e15 wei）
     - `_saleDurationInSeconds`: 300
     - `_minPurchase`: 10000000000000000（0.01 ETH，1e16 wei）
     - `_maxPurchase`: 1000000000000000000（1 ETH，1e18 wei）
     - `_projectOwner`: 你的钱包地址（用于后续调用 finalizeSale）
5. 点击 **Deploy**，部署成功后复制合约地址。

## 测试验证步骤

1. **连接前端**  
   在本页面连接 MetaMask（与 Remix 部署时同一网络），将合约地址粘贴到输入框，点击「初始化合约」。

2. **验证只读数据**  
   点击「刷新销售与代币信息」，确认：
   - name、symbol、总供应量正确
   - 代币单价、最小/最大购买（ETH）正确
   - 销售状态为「进行中」，剩余时间递减，剩余可售代币等于总供应量（尚未有人购买）

3. **购买代币**  
   在「用 ETH 购买代币」输入 0.01～1 之间的数值（单位 ETH），点击「发送 buyTokens」并在 MetaMask 确认。  
   刷新后检查：
   - 「我的代币余额」增加
   - 「剩余可售代币」减少
   - 「已募集 ETH」增加

4. **结束销售（项目方）**  
   等待 `saleEndTime` 过后（部署时若设为 300 秒，则约 5 分钟后），用 **projectOwner** 账户在本页点击「结束销售 finalizeSale()」或在 Remix 调用 `finalizeSale`。  
   成功后：
   - 销售状态变为「已结束」，finalized 为 true
   - 合约内 ETH 应已转至 projectOwner 地址

5. **代币转账**  
   销售结束后，用持有代币的账户在本页填写「接收地址」和「转账数量」，点击「发送 transfer()」，确认交易后刷新，双方余额应正确变化。

## 注意事项

- 预售期间（未 finalize）代币不能自由 transfer，只能通过 buyTokens 获得。
- finalizeSale 只能由 projectOwner 调用，且必须在 block.timestamp > saleEndTime 之后。
- 前端仅作教学与本地测试，部署到公网时请自行处理合约审计与安全配置。
