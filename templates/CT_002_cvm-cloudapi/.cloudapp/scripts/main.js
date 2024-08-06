const https = require("https");
const http = require("http");
const crypto = require("crypto");

/**
 * 获取临时密钥
 */
async function getTempSecret() {
  return new Promise((resolve, reject) => {
    // 读环境变量
    const camRole = process.env.CLOUDAPP_CAM_ROLE;

    // 可以从文件读取（取决于安装应用时cam角色记录的方式）
    // const camRole = fs.readFileSync("/usr/local/cloudapp/.cloudapp_cam_role", "utf8");

    // 设置请求的选项
    const options = {
      hostname: "metadata.tencentyun.com", // 目标主机名
      port: 80, // 端口号
      path: `/meta-data/cam/security-credentials/${camRole}`, // 请求路径
      method: "GET", // 请求方法
    };

    // 创建请求
    const req = http.request(options, (res) => {
      let data = "";
      res.on("data", (chunk) => {
        data += chunk;
      });

      res.on("end", () => {
        console.log(data);
        resolve(data);
      });
    });

    // 错误处理
    req.on("error", (e) => {
      console.error(`请求遇到问题: ${e.message}`);
      reject(`请求遇到问题: ${e.message}`);
    });

    // 结束请求
    req.end();
  });
}

function sha256(message, secret = "", encoding) {
  const hmac = crypto.createHmac("sha256", secret);
  return hmac.update(message).digest(encoding);
}
function getHash(message, encoding = "hex") {
  const hash = crypto.createHash("sha256");
  return hash.update(message).digest(encoding);
}
function getDate(timestamp) {
  const date = new Date(timestamp * 1000);
  const year = date.getUTCFullYear();
  const month = ("0" + (date.getUTCMonth() + 1)).slice(-2);
  const day = ("0" + date.getUTCDate()).slice(-2);
  return `${year}-${month}-${day}`;
}

/**
 * 调用云API
 */
async function callAPI(secretId, secretKey, token) {
  const SECRET_ID = secretId;
  const SECRET_KEY = secretKey;
  const TOKEN = token;

  const host = "cvm.tencentcloudapi.com";
  const service = "cvm";
  const region = "ap-guangzhou";
  const action = "DescribeInstances";
  const version = "2017-03-12";
  const timestamp = parseInt(String(new Date().getTime() / 1000));
  const date = getDate(timestamp);
  const payload = "{}";

  // ************* 步骤 1：拼接规范请求串 *************
  const signedHeaders = "content-type;host";
  const hashedRequestPayload = getHash(payload);
  const httpRequestMethod = "POST";
  const canonicalUri = "/";
  const canonicalQueryString = "";
  const canonicalHeaders =
    "content-type:application/json; charset=utf-8\n" + "host:" + host + "\n";

  const canonicalRequest =
    httpRequestMethod +
    "\n" +
    canonicalUri +
    "\n" +
    canonicalQueryString +
    "\n" +
    canonicalHeaders +
    "\n" +
    signedHeaders +
    "\n" +
    hashedRequestPayload;

  // ************* 步骤 2：拼接待签名字符串 *************
  const algorithm = "TC3-HMAC-SHA256";
  const hashedCanonicalRequest = getHash(canonicalRequest);
  const credentialScope = date + "/" + service + "/" + "tc3_request";
  const stringToSign =
    algorithm +
    "\n" +
    timestamp +
    "\n" +
    credentialScope +
    "\n" +
    hashedCanonicalRequest;

  // ************* 步骤 3：计算签名 *************
  const kDate = sha256(date, "TC3" + SECRET_KEY);
  const kService = sha256(service, kDate);
  const kSigning = sha256("tc3_request", kService);
  const signature = sha256(stringToSign, kSigning, "hex");

  // ************* 步骤 4：拼接 Authorization *************
  const authorization =
    algorithm +
    " " +
    "Credential=" +
    SECRET_ID +
    "/" +
    credentialScope +
    ", " +
    "SignedHeaders=" +
    signedHeaders +
    ", " +
    "Signature=" +
    signature;

  // ************* 步骤 5：构造并发起请求 *************
  const headers = {
    Authorization: authorization,
    "Content-Type": "application/json; charset=utf-8",
    Host: host,
    "X-TC-Action": action,
    "X-TC-Timestamp": timestamp,
    "X-TC-Version": version,
  };

  if (region) {
    headers["X-TC-Region"] = region;
  }
  if (TOKEN) {
    headers["X-TC-Token"] = TOKEN;
  }

  const options = {
    hostname: host,
    method: httpRequestMethod,
    headers,
  };

  const req = https.request(options, (res) => {
    let data = "";
    res.on("data", (chunk) => {
      data += chunk;
    });

    res.on("end", () => {
      console.log(data);
    });
  });

  req.on("error", (error) => {
    console.error(error);
  });

  req.write(payload);

  req.end();
}

(async function startup() {
  const secret = await getTempSecret();
  console.log(`密钥结果：${secret}，类型：${typeof secret}`);
  const jsonData = JSON.parse(secret);
  const { TmpSecretId, TmpSecretKey, Token } = jsonData;
  callAPI(TmpSecretId, TmpSecretKey, Token);
})();
