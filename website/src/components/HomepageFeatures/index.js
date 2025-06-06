import clsx from 'clsx';
import Heading from '@theme/Heading';
import useBaseUrl from '@docusaurus/useBaseUrl';
import styles from './styles.module.css';

const FeatureList = [
  {
    title: 'Flutter-Friendly Hive Auth',
    imgSrc: '/img/undraw_docusaurus_mountain.png',
    width: 272,
    height: 172,
    description: (
      <>
        HiveFlutterKit is designed for seamless integration into your Flutter
        applications, allowing you to add Hive authentication with minimal setup.
      </>
    ),
    width: 272,
    height: 172,
  },
  {
    title: 'Connect to Hive, Not Complexity',
    imgSrc: '/img/undraw_docusaurus_tree.png',
    width: 260,
    height: 138,
    description: (
      <>
        HiveFlutterKit handles the underlying complexities of Hive authentication,
        so you can focus on building great user experiences on the Hive blockchain.
      </>
    ),
    width: 260,
    height: 138,
  },
  {
    title: 'Open Source & Community Driven',
    imgSrc: '/img/undraw_docusaurus_react.png',
    width: 282,
    height: 166,
    description: (
      <>
        HiveFlutterKit is an open-source project built for the Hive community.
        Contributions are welcome to help it grow and thrive!
      </>
    ),
    width: 282,
    height: 166,
  },
];

function Feature({imgSrc, title, description, width, height}) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <img src={useBaseUrl(imgSrc)} alt={title} className={styles.featureSvg} width={width} height={height} />
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures() {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
