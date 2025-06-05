import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

const FeatureList = [
  {
    title: 'Flutter-Friendly Hive Auth',
    Svg: require('@site/static/img/undraw_docusaurus_mountain.png').default,
    description: (
      <>
        HiveFlutterKit is designed for seamless integration into your Flutter
        applications, allowing you to add Hive authentication with minimal setup.
      </>
    ),
  },
  {
    title: 'Connect to Hive, Not Complexity',
    Svg: require('@site/static/img/undraw_docusaurus_tree.png').default,
    description: (
      <>
        HiveFlutterKit handles the underlying complexities of Hive authentication,
        so you can focus on building great user experiences on the Hive blockchain.
      </>
    ),
  },
  {
    title: 'Open Source & Community Driven',
    Svg: require('@site/static/img/undraw_docusaurus_react.png').default,
    description: (
      <>
        HiveFlutterKit is an open-source project built for the Hive community.
        Contributions are welcome to help it grow and thrive!
      </>
    ),
  },
];

function Feature({Svg, title, description}) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <Svg className={styles.featureSvg} role="img" />
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
