import development from './development';
import production from './production';

const cloudapp = production || development;

const { callAPI, run } = cloudapp;

export default cloudapp;

export { callAPI, run };
