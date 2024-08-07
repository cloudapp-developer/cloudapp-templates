// 腾讯云 Node.JS SDK
const tencentcloud = require("tencentcloud-sdk-nodejs");

const http = require("http");

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

/**
 * 调用云API（Node.JS SDK示例）
 */
function callCloudAPI(secretId, secretKey, token) {
  // 导入对应产品模块的client models。
  const CvmClient = tencentcloud.cvm.v20170312.Client;

  // 实例化要请求产品(以cvm为例)的client对象
  const client = new CvmClient({
    // 为了保护密钥安全，建议将密钥设置在环境变量中或者配置文件中，请参考本文凭证管理章节。
    // 硬编码密钥到代码中有可能随代码泄露而暴露，有安全隐患，并不推荐。
    credential: { secretId, secretKey, token },

    // 产品地域
    region: "ap-guangzhou",
    // 可选配置实例
    profile: {
      signMethod: "TC3-HMAC-SHA256", // 签名方法
      httpProfile: {
        reqMethod: "POST", // 请求方法
        reqTimeout: 30, // 请求超时时间，默认60s
        // proxy: "http://127.0.0.1:8899" // http请求代理
      },
    },
  });

  // 通过client对象调用想要访问的接口（Action），需要传入请求对象（Params）以及响应回调函数
  // 即：client.Action(Params).then(res => console.log(res), err => console.error(err))
  // 如：查询云服务器可用区列表
  client.DescribeZones().then(
    (data) => {
      console.log(data);
    },
    (err) => {
      console.error("error", err);
    }
  );
}

(async function startup() {
  const secret = await getTempSecret();
  console.log(`密钥结果：${secret}，类型：${typeof secret}`);
  const jsonData = JSON.parse(secret);
  const { TmpSecretId, TmpSecretKey, Token } = jsonData;
  callCloudAPI(TmpSecretId, TmpSecretKey, Token);
})();
